# server.py
# FastAPI + Qwen2-VL-2B-Instruct en LOCAL GPU UNIQUEMENT, avec
# vérification/téléchargement des poids dans un dossier dédié.
# Endpoint: POST /caption-file  -> { "text": "..." }

import io
import os
from pathlib import Path
from typing import Optional

import torch
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.responses import JSONResponse
from PIL import Image
from transformers import AutoProcessor
from huggingface_hub import snapshot_download
import uvicorn
import threading

# ── Concurrence (configurable via env)
MAX_CONCURRENT = int(os.getenv("MAX_CONCURRENT", "1"))          # 1 = strictement séquentiel
ACQUIRE_TIMEOUT_S = float(os.getenv("ACQUIRE_TIMEOUT_S", "0"))  # 0 = rejet immédiat si occupé
RETRY_AFTER_S = int(os.getenv("RETRY_AFTER_S", "1"))            # conseil client pour retenter

_GEN_SEMAPHORE = threading.Semaphore(MAX_CONCURRENT)

# ──────────────────────────────────────────────────────────────────────────────
# 0) GPU obligatoire, pas de fallback CPU
# ──────────────────────────────────────────────────────────────────────────────
if not torch.cuda.is_available():
    raise RuntimeError(
        "CUDA est requis. Aucune exécution CPU : installez PyTorch avec CUDA et une carte NVIDIA."
    )

# ──────────────────────────────────────────────────────────────────────────────
# 1) Paramètres modèle + dossier de poids
# ──────────────────────────────────────────────────────────────────────────────
MODEL_ID = "Qwen/Qwen2-VL-2B-Instruct"

# Dossier local où stocker les poids (choisissez un emplacement persistant/rapide)
# Exemple Windows : D:/LAURA/llm/weights/Qwen2-VL-2B-Instruct
WEIGHTS_DIR = Path(os.environ.get(
    "WEIGHTS_DIR",
    r"D:\hackaton\weights\Qwen2-VL-2B-Instruct"
)).resolve()

# Optionnel : répertoire de cache HF (si vous voulez centraliser)
# os.environ.setdefault("HF_HOME", r"D:\HF_CACHE")

# Après téléchargement, activez le mode hors-ligne pour empêcher tout accès réseau
os.environ.setdefault("HF_HUB_OFFLINE", "1")


def ensure_weights(model_id: str, dest_dir: Path) -> Path:
    """
    Garantit la présence complète des poids en local.
    1) Tente un snapshot_download vers dest_dir (réseau si disponible).
    2) Si offline, vérifie que dest_dir contient déjà un snapshot valide.
    3) Retourne le chemin local final à utiliser par from_pretrained(...).
    """
    dest_dir.mkdir(parents=True, exist_ok=True)

    # Drapeau OFFLINE éventuellement imposé par l'env.
    offline_env = os.environ.get("HF_HUB_OFFLINE", "0") == "1"

    try:
        # Si on n'est PAS explicitement offline, on force un snapshot complet.
        if not offline_env:
            local_path = snapshot_download(
                repo_id=model_id,
                local_dir=str(dest_dir),
                local_dir_use_symlinks=False,  # copie réelle, plus robuste sous Windows
                resume_download=True,          # reprend si interrompu
                # allow_patterns=None  # on laisse tout prendre (poids + tokenizer + processors + code)
            )
            return Path(local_path)

        # Mode offline : aucune requête réseau
        local_path = snapshot_download(
            repo_id=model_id,
            local_dir=str(dest_dir),
            local_dir_use_symlinks=False,
            local_files_only=True,
        )
        return Path(local_path)

    except Exception as e:
        # Erreur réseau mais peut-être que les fichiers sont déjà là
        # On valide minimalement la présence de fichiers clés
        needed = [
            "config.json",
            "generation_config.json",
            "tokenizer.json",
        ]
        # On tolère weights .safetensors shardés
        has_any_weight = any(p.suffix == ".safetensors" for p in dest_dir.rglob("*"))
        has_all_meta = all((dest_dir / name).exists() or list(dest_dir.rglob(name)) for name in needed)

        if has_any_weight and has_all_meta:
            return dest_dir

        raise RuntimeError(
            f"Echec de téléchargement des poids ({model_id}) et aucun snapshot local complet détecté : {e}"
        )


# ──────────────────────────────────────────────────────────────────────────────
# 2) Chargement modèle/processor depuis WEIGHTS_DIR (local only)
# ──────────────────────────────────────────────────────────────────────────────
weights_path = ensure_weights(MODEL_ID, WEIGHTS_DIR)

dtype = torch.bfloat16 if torch.cuda.is_bf16_supported() else torch.float16
torch.backends.cudnn.benchmark = True

processor = AutoProcessor.from_pretrained(
    weights_path,
    trust_remote_code=True,
    use_fast=False
)

try:
    from transformers import AutoModelForImageTextToText  # >= 4.4x+
    model = AutoModelForImageTextToText.from_pretrained(
        weights_path, dtype=dtype, device_map="auto", trust_remote_code=True
    )
except Exception:
    try:
        from transformers import AutoModelForVision2Seq  # déprécié mais encore présent
        model = AutoModelForVision2Seq.from_pretrained(
            weights_path, dtype=dtype, device_map="auto", trust_remote_code=True
        )
    except Exception:
        # Fallback spécifique Qwen2-VL si ni l’un ni l’autre n’existe
        from transformers import Qwen2VLForConditionalGeneration
        model = Qwen2VLForConditionalGeneration.from_pretrained(
            weights_path, dtype=dtype, device_map="auto", trust_remote_code=True
        )
model.eval()


# ──────────────────────────────────────────────────────────────────────────────
# 3) Utilitaire : bytes → PIL.Image (RGB)
# ──────────────────────────────────────────────────────────────────────────────
def pil_from_bytes(data: bytes) -> Image.Image:
    try:
        img = Image.open(io.BytesIO(data))
        if img.mode != "RGB":
            img = img.convert("RGB")
        return img
    except Exception as e:
        raise ValueError(f"Image invalide: {e}")


# ──────────────────────────────────────────────────────────────────────────────
# 4) Génération locale (GPU)
# ──────────────────────────────────────────────────────────────────────────────
@torch.inference_mode()
def caption_local(
    img: Image.Image,
    prompt: Optional[str] = None,
    max_new_tokens: int = 128,
    temperature: float = 0.2,
) -> str:
    user_text = prompt or "Describe this image in accurate, concise detail."

    messages = [
        {
            "role": "user",
            "content": [
                {"type": "image", "image": img},
                {"type": "text",  "text": user_text},
            ],
        }
    ]

    chat_text = processor.apply_chat_template(
        messages, tokenize=False, add_generation_prompt=True
    )
    inputs = processor(
        text=[chat_text],
        images=[img],
        return_tensors="pt"
    )
    inputs = {k: v.to(model.device, non_blocking=True) for k, v in inputs.items()}

    gen_kwargs = dict(
        max_new_tokens=int(max_new_tokens),
        do_sample=(float(temperature) > 0.0),
        temperature=max(0.0, min(float(temperature), 1.5)),
        use_cache=True,
    )

    output_ids = model.generate(**inputs, **gen_kwargs)
    gen_only_ids = output_ids[:, inputs["input_ids"].shape[1]:]
    text = processor.batch_decode(gen_only_ids, skip_special_tokens=True)[0]
    return text.strip()


# ──────────────────────────────────────────────────────────────────────────────
# 5) FastAPI
# ──────────────────────────────────────────────────────────────────────────────
app = FastAPI(title="Local Caption (Qwen2-VL-2B-Instruct, weights verified)")

@app.get("/healthz")
def healthz():
    try:
        n_weights = len(list(weights_path.rglob("*.safetensors")))
        # Attention : _GEN_SEMAPHORE._value est interne ; on l'utilise juste à titre indicatif
        current_available = getattr(_GEN_SEMAPHORE, "_value", None)
        return {
            "status": "ok",
            "weights_dir": str(weights_path),
            "num_safetensors": n_weights,
            "device": str(model.device),
            "dtype": str(dtype),
            "offline": os.environ.get("HF_HUB_OFFLINE", "0"),
            "concurrency": {
                "max_concurrent": MAX_CONCURRENT,
                "acquire_timeout_s": ACQUIRE_TIMEOUT_S,
                "retry_after_s": RETRY_AFTER_S,
                "slots_available_hint": current_available,
            },
        }
    except Exception as e:
        return {"status": "error", "detail": str(e)}

@app.post("/caption-file")
def caption_file(
    file: UploadFile = File(...),
    prompt: Optional[str] = Form(None),
    max_new_tokens: int = Form(128),
    temperature: float = Form(0.2),
):
    try:
        img_bytes = file.file.read()
        img = pil_from_bytes(img_bytes)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    # ── Limitation de concurrence : on essaie d'entrer dans la section critique
    acquired = _GEN_SEMAPHORE.acquire(timeout=ACQUIRE_TIMEOUT_S)
    if not acquired:
        # GPU occupé -> on rejette la requête
        raise HTTPException(
            status_code=429,
            detail="Busy: the captioner is processing another image.",
            headers={"Retry-After": str(RETRY_AFTER_S)},
        )

    try:
        # Section critique (GPU)
        text = caption_local(
            img=img,
            prompt=prompt,
            max_new_tokens=int(max_new_tokens),
            temperature=float(temperature),
        )
        return JSONResponse({"text": text})
    except torch.cuda.OutOfMemoryError:
        raise HTTPException(
            status_code=500,
            detail="CUDA OOM: Réduisez max_new_tokens, fermez d'autres processus GPU, ou utilisez un modèle plus petit."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur génération: {e}")
    finally:
        _GEN_SEMAPHORE.release()


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8089)