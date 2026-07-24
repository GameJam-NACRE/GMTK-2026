# Fichiers de Signaux globaux.
extends Node


# ==== Signaux CountDown ============

# Ajoute du temps au CD en secondes
@warning_ignore("unused_signal")
signal add_time(sec: int)

# Supprime du temps au CD en secondes
@warning_ignore("unused_signal")
signal remove_time(sec: int)

# Indique la fin du countdown
@warning_ignore("unused_signal")
signal countdown_end()

# Indique que la transition d'intro du countdown est terminé
@warning_ignore("unused_signal")
signal intro_countdown_end()

# ==== Signaux Player ============

# Ajoute 1 pièce au joueur
@warning_ignore("unused_signal")
signal add_coin()

# Ajoute 1 key au joueur
@warning_ignore("unused_signal")
signal add_key()

# Ajoute l'épée au joueur
@warning_ignore("unused_signal")
signal add_sword()

# ==== Signaux Level ============

# Indique l'id du Dialogue à lancer
@warning_ignore("unused_signal")
signal launch_dialogue(id: int)

# Indique la fin de chargement d'un niveau
@warning_ignore("unused_signal")
signal level_loaded()

# Indique la fin d'un niveau
@warning_ignore("unused_signal")
signal level_ended()

# ==== Signaux Composants ============

# Indique qu'un flag de fin de niveau à été atteint
@warning_ignore("unused_signal")
signal flag_reached()

# ==== Signaux HUD ============

# Indique que l'écran est totalement noir
@warning_ignore("unused_signal")
signal faded_to_black

# Indique que le fade a terminé
@warning_ignore("unused_signal")
signal fade_finished
