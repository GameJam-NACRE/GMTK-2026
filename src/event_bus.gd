# Fichiers de Signaux globaux.
extends Node

# ==== Signaux CountDown ============

# Ajoute du temps au CD en secondes
signal add_time(sec: int)

# Supprime du temps au CD en secondes
signal remove_time(sec: int)

# ==== Signaux Player ============

# Ajoute 1 pièce au joueur
signal add_coin()
