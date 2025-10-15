### Prérequis
- Python 3.x installé.

### Installation des dépendances
1. Ouvrez le terminal dans le dossier du serveur.
2. Exécutez `pip install Flask`.

### Lancer le serveur
- Exécutez `python server.py`.
- Notez l'adresse IP affichée par le serveur (ex: `http://192.168.1.32:5000`). Cette IP doit être configurée dans l'application mobile.

### Fonctionnalités
- Reçoit les images envoyées par l'application mobile.
- Crée un dossier `captured_images/session_X/` pour chaque session de capture et y enregistre les images.
