# server.py
from flask import Flask, request, jsonify
import os
import time
import socket # Pour obtenir l'adresse IP locale

app = Flask(__name__)

UPLOAD_ROOT_FOLDER = 'captured_images' # Renommé pour clarté
os.makedirs(UPLOAD_ROOT_FOLDER, exist_ok=True) # Créer le dossier racine s'il n'existe pas

@app.route('/upload_image', methods=['POST'])
def upload_image():
    # Vérifier si le fichier image est présent
    if 'image' not in request.files:
        return jsonify({"error": "No 'image' file part in the request"}), 400

    file = request.files['image']

    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    # Récupérer l'ID de session si envoyé
    session_id = request.form.get('session_id')

    # Définir le dossier de destination
    if session_id:
        session_folder = os.path.join(UPLOAD_ROOT_FOLDER, f"session_{session_id}")
    else:
        # Fallback si aucun ID de session n'est fourni
        session_folder = os.path.join(UPLOAD_ROOT_FOLDER, "unsorted")
        print("Avertissement: Aucun ID de session fourni, enregistrement dans 'unsorted'.")

    os.makedirs(session_folder, exist_ok=True) # Créer le dossier de session s'il n'existe pas

    if file:
        timestamp = int(time.time())
        original_extension = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
        filename = f"capture_{timestamp}.{original_extension}"
        filepath = os.path.join(session_folder, filename) # Chemin complet incluant le dossier de session

        try:
            file.save(filepath)
            print(f"Image enregistrée: {filepath} (Session ID: {session_id or 'N/A'})")
            return jsonify({"message": "Image received successfully", "filename": filename, "session_id": session_id}), 200
        except Exception as e:
            print(f"Erreur lors de l'enregistrement de l'image (Session ID: {session_id or 'N/A'}): {e}")
            return jsonify({"error": f"Failed to save image: {e}"}), 500

    return jsonify({"error": "An unexpected error occurred"}), 500

if __name__ == '__main__':
    # Obtenir l'adresse IP locale du Mac
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Cette commande tente de se connecter à une adresse externe pour trouver l'IP locale.
        # Elle ne va pas réellement envoyer de données.
        s.connect(('192.255.255.255', 1))
        IP_ADDRESS = s.getsockname()[0]
    except Exception:
        IP_ADDRESS = '127.0.0.1' # Fallback si ça échoue (devrait être l'IP réelle)
    finally:
        s.close()

    print(f"Serveur Flask démarré sur http://{IP_ADDRESS}:5000")
    print(f"Endpoint pour l'upload d'images: http://{IP_ADDRESS}:5000/upload_image")
    print("Assurez-vous que l'application mobile est configurée avec cette adresse IP.")
    app.run(host='0.0.0.0', port=5000, debug=True)
