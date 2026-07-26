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

@warning_ignore("unused_signal")
signal countdown_final_mode()

@warning_ignore("unused_signal")
signal countdown_clicker_mode()

@warning_ignore("unused_signal")
signal countdown_hud_mode()

@warning_ignore("unused_signal")
signal stop_countdown()

@warning_ignore("unused_signal")
signal end_level_clicker()

@warning_ignore("unused_signal")
signal send_time_countdown(time: float)

@warning_ignore("unused_signal")
signal ask_time_countdown()
#
# ==== Signaux Player ============

# Ajoute 1 pièce au joueur
@warning_ignore("unused_signal")
signal add_coin()

@warning_ignore("unused_signal")
signal has_5_coins()

# Ajoute 1 key au joueur
@warning_ignore("unused_signal")
signal add_key()

@warning_ignore("unused_signal")
signal use_key()

@warning_ignore("unused_signal")
signal no_key()

@warning_ignore("unused_signal")
signal one_key()

@warning_ignore("unused_signal")
signal got_key()
# Ajoute l'épée au joueur
@warning_ignore("unused_signal")
signal add_sword()

@warning_ignore("unused_signal")
signal enable_top_down()

# ==== Signaux HUD ============

# Indique la position du contact Joueur/Ennemi
@warning_ignore("unused_signal")
signal enemy_contact(enemy_position: Vector2)

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

@warning_ignore("unused_signal")
signal countdown_critical()

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
