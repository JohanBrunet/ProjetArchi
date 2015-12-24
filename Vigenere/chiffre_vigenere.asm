###############################################################################################################################
############ 				                Chiffre de Vigen�re               			   ############
############        				MIPS PROJECT - Polytech Montpellier     			   ############
############            				Author : Johan BRUNET               			   ############
###############################################################################################################################

.data
	menu: .asciiz "                         MENU\n 1- Cryptage de chaine\n 2- D�ryptage de chaine\n 3- Cryptage de fichier\n 4- D�ryptage de fichier\n 5- Sortie\n"
	demande_continuer : .asciiz "Voulez vous continuer ?"
	
	demande_chaine_cryptage: .asciiz "\n Veuillez entrer la chaine � crypter (majuscules uniquement)\n"
	demande_cle_cryptage: .asciiz "\n Veuillez entrer la cl� de cryptage (majuscules uniquement)\n"
	msg_chaine_cryptee: .asciiz "\n Chaine crypt�e : \n"
	chaine_cryptee: .space 255
	
	demande_chaine_decryptage: .asciiz "\n Veuillez entrer la chaine � d�crypter (majuscules uniquement)\n"
	demande_cle_decryptage: .asciiz "\n Veuillez entrer la cl� de d�cryptage (majuscules uniquement)\n"
	msg_chaine_decryptee: .asciiz "\n Chaine d�crypt�e : \n"
	chaine_decryptee: .space 255
	
	chaine: .space 2000
	cle: .space 255
	cle_repetee: .space 255
	
	fichier_entree: .space 255
	fichier_sortie: .asciiz "fichier_sortie.txt"
	msg_fichier_ecrit: .asciiz "Votre fichier a �t� �crit avec succ�s"
	
	demande_fichier_cryptage: .asciiz "\n Veuillez entrer le nom du fichier � crypter (extension .txt)\n"
	demande_fichier_decryptage: .asciiz "\n Veuillez entrer le nom du fichier � d�crypter (extension .txt)\n"
	
.text

# Remise � 0 des registres
# Appel� � la fin du cryptage ou d�criptage
# Redirige vers le menu
effacer_registres:
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $v0, 0
	li $v1, 0
	j affiche_menu
	
# Affichage du menu, redirige vers l'une des 4 fonctions
affiche_menu:
	# Affichage du menu dans une fen�tre graphique
	li $v0, 51
	la $a0, menu
	syscall
	move $t0, $a0 
	# Branchement vers la fonction d�sir�e en fonction de la r�ponse utilisateur
	beq $t0, 1, cryptage_chaine
	beq $t0, 2, decryptage_chaine
	beq $t0, 3, cryptage_fichier
	beq $t0, 4, decryptage_fichier
	beq $t0, 5, exit
	j affiche_menu

##################################################################################################################################

# Premi�re fonction, demande la saisie d'une chaine de caract�res et d'une cl�
# Renvoie la chaine crypt�e en fonction de la cl� selon, le chiffrement de Vig�n�re

##################################################################################################################################

cryptage_chaine: 
	# Demande de la saisie de la chaine � crypter et la stocke dans "chaine" (taille maximale de 255 caract�res)
	li $v0, 54
	la $a0, demande_chaine_cryptage
	la $a1, chaine
	la $a2, 255
	syscall
	# Demande de la saisie de la cl� de cryptage et la stocke dans "cle" (taille maximale de 255 caract�res)
	li $v0, 54
	la $a0, demande_cle_cryptage
	la $a1, cle
	la $a2, 255
	syscall
	jal contact_cle_chaine			# Saut avec retour vers la routine de contact entre la cl� et la chaine
	jal routine_cryptage			# Saut avec retour vers la routine de de cryptage de chaine
	# Affichage de la chaine crypt�e
	li $v0, 59
	la $a0, msg_chaine_cryptee
	la $a1, chaine_cryptee
	syscall
	j continuer

##################################################################################################################################

# Deuxi�me fonction, demande la saisie d'une chaine de caract�res et d'une cl�
# Renvoie la chaine d�crypt�e en fonction de la cl�, selon le chiffrement de Vig�n�re

##################################################################################################################################

# Renvoie la chaine d�crypt�e
decryptage_chaine: 
	# Demande de la saisie de la chaine � d�crypter et la stocke dans "chaine" (taille maximale de 255 caract�res)
	li $v0, 54
	la $a0, demande_chaine_decryptage
	la $a1, chaine
	la $a2, 255
	syscall
	# Demande de la saisie de la cl� de d�cryptage et la stocke dans "cle" (taille maximale de 255 caract�res)
	li $v0, 54
	la $a0, demande_cle_decryptage
	la $a1, cle
	la $a2, 255
	syscall
	jal contact_cle_chaine			# Saut avec retour vers la routine de contact entre la cl� et la chaine
	jal routine_decryptage			# Saut avec retour vers la routine de de d�cryptage de chaine
	# Affichage de la chaine d�crypt�e
	li $v0, 59
	la $a0, msg_chaine_decryptee
	la $a1, chaine_decryptee
	syscall
	j continuer
  
##################################################################################################################################

# Troisi�me fonction, demande la saisie d'un nom de fichier et d'une cl�
# Renvoie le fichier crypt�, dans un nouveau fichier, en fonction de la cl�, selon le chiffrement de Vig�n�re

##################################################################################################################################

cryptage_fichier:
	li $v0, 54
	la $a0, demande_fichier_cryptage
	la $a1, fichier_entree
	la $a2, 255
	syscall
	
	# Demande de la saisie de la cl� de cryptage et la stocke dans "cle" (taille maximale de 255 caract�res)
	li $v0, 54
	la $a0, demande_cle_cryptage
	la $a1, cle
	la $a2, 255
	syscall
	jal nettoyer_nom_fichier
	
	# Ouverture d'un fichier en lecture
	li   $v0, 13       			# Appel syst�me pour l'ouverture de fichier
	la   $a0, fichier_entree     		# Nom du fichier � ouvrir
	li   $a1, 0        			# Ouverture en lecture
	li   $a2, 0				# On ignore le mode d'ouverture
	syscall            			# Ouverture du fichier (descripteur de fichier retourn� dans $v0)
	move $s6, $v0      			# Stockage du descripteur de fichier 
	# Lecture dans un fichier
	li   $v0, 14       			# Appel syst�me pour lire dans un fichier
	move $a0, $s6      			# Descripteur du fichier 
	la   $a1, chaine   			# Adresse du buffer dans lequel enregistrer la lecture
	li   $a2, 2000     			# Taille du buffer 'en dur'
	syscall            			# Lecture du fichier
	# Fermeture du fichier 
	li   $v0, 16      			# Appel syst�me pour la fermeture de fichier
	move $a0, $s6     			# Descripteur du fichier � fermer
	syscall           			# Fermetur du fichier

	jal contact_cle_chaine
	jal routine_cryptage

  	# Ouverture en �criture d'un fichier inexistant
  	li   $v0, 13       			# Appel syst�me pour l'ouverture de fichier
  	la   $a0, fichier_sortie     		# Nom du fichier de sortie
  	li   $a1, 1        			# Ouverture en �criture
  	li   $a2, 0        			# On ignore le mode d'ouverture
  	syscall            			# Ouverture du fichier (descripteur de fichier retourn� dans $v0)
  	move $s6, $v0      			# Stockage du descripteur de fichier
  	# Ecriture dans le fichier ouvert
  	li   $v0, 15       			# Appel syst�me pour �crire dans un fichier
  	move $a0, $s6      			# Descripteur du fichier 
  	la   $a1, chaine_cryptee   		# Adresse du buffer depuis lequel on �crit
 	li   $a2, 2000       			# Taille du buffer 'en dur'
 	syscall            			# Ecriture dans le fichier
  	# Fermeture du fichier 
	li   $v0, 16      			# Appel syst�me pour la fermeture de fichier
	move $a0, $s6     			# Descripteur du fichier � fermer
	syscall           			# Fermetur du fichier
	
  	# Affichage d'un message pour notifier � l'utilisateur que le fichier a bien �t� �crit
  	li $v0, 55
  	la $a0, msg_fichier_ecrit
  	la $a1, 1
  	syscall
  	j continuer

##################################################################################################################################

# Quatri�me fonction, demande la saisie d'une chaine de caract�res et d'une cl�
# Renvoie le fichier d�crypt�, dans un nouveau fichier, en fonction de la cl�, selon le chiffrement de Vig�n�re

##################################################################################################################################


decryptage_fichier:
	li $v0, 54
	la $a0, demande_fichier_decryptage
	la $a1, fichier_entree
	la $a2, 255
	syscall
	
	# Demande de la saisie de la cl� de cryptage et la stocke dans "cle" (taille maximale de 255 caract�res)
	li $v0, 54
	la $a0, demande_cle_decryptage
	la $a1, cle
	la $a2, 255
	syscall
	jal nettoyer_nom_fichier
	
	# Ouverture d'un fichier en lecture
	li   $v0, 13       			# Appel syst�me pour l'ouverture de fichier
	la   $a0, fichier_entree     		# Nom du fichier � ouvrir
	li   $a1, 0        			# Ouverture en lecture
	li   $a2, 0				# On ignore le mode d'ouverture
	syscall            			# Ouverture du fichier (descripteur de fichier retourn� dans $v0)
	move $s6, $v0      			# Stockage du descripteur de fichier 
	# Lecture dans un fichier
	li   $v0, 14       			# Appel syst�me pour lire un fichier
	move $a0, $s6      			# Descripteur du fichier 
	la   $a1, chaine   			# Adresse du buffer dans lequel enregistrer la lecture
	li   $a2, 2000     			# Taille du buffer 'en dure'
	syscall            			# Lecture du fichier
	# Fermeture du fichier 
	li   $v0, 16      			# Appel syst�me pour la fermeture de fichier
	move $a0, $s6     			# Descripteur du fichier � fermer
	syscall           			# Fermetur du fichier

	jal contact_cle_chaine
	jal routine_decryptage

  	# Ouverture d'un fichier en lecture
	li   $v0, 13       			# Appel syst�me pour l'ouverture de fichier
	la   $a0, fichier_sortie     		# Nom du fichier � ouvrir
	li   $a1, 1        			# Ouverture en �criture
	li   $a2, 0				# On ignore le mode d'ouverture
	syscall            			# Ouverture du fichier (descripteur de fichier retourn� dans $v0)
	move $s6, $v0      			# Stockage du descripteur de fichier
  	# Ecriture dans le fichier
  	li   $v0, 15       			# Appel syst�me pour l'�criture dans un fichier
  	move $a0, $s6      			# Descripteur du fichier 
  	la   $a1, chaine_decryptee   		# Adresse du buffer depuis lequel �crire
 	li   $a2, 2000       			# Taille du buffer 'en dure'
 	syscall            			# Ecriture dans le fichier
  	# Fermeture du fichier 
	li   $v0, 16      			# Appel syst�me pour la fermeture de fichier
	move $a0, $s6     			# Descripteur du fichier � fermer
	syscall           			# Fermetur du fichier
  	# Affichage d'un message pour notifier � l'utilisateur que le fichier a bien �t� �crit
  	li $v0, 55
  	la $a0, msg_fichier_ecrit
  	la $a1, 1
  	syscall
  	j continuer

##################################################################################################################################

# Routines permettant de faire le contact entre la cl� et la chaine, le cryptage et le d�cryptage de chaines de caract�res

##################################################################################################################################

# R�p�te la cl� afin d'avoir la m�me taille que la chaine
contact_cle_chaine:
	# Allocation et enregistrement de l'adresse de retour dans la pile
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	# Chargement des chaines et positionnement sur le premier caract�re
	la $t0, chaine
	lb $t1, 0($t0)
	la $t4, cle_repetee	
	
	# Pour revenir au premier caract�re de la cl� lorsqu'on la r�p�te 
	debut_cle:
	la $t2, cle
	lb $t3, 0($t2)
	# D�but de la boucle de r�p�tition de la cl�
	boucle:
	beq $t1, 10, retour_appelant		# Retour � l'appelant si on a atteint la fin de la chaine (10 = \n)
	beq $t1, 0, retour_appelant		# Retour � l'appelant si on a atteint la fin de la chaine (sans line feed) (0 = \0)
	beq $t3, 10, debut_cle			# Retour au d�but de la cl� lorsqu'elle se termine (10 = \n)
	beq $t1, 32, ajout_espace		# On ajoute un espace dans la cl� r�p�t�e lorsqu'il y a un espace dans la chaine
	sb $t3, ($t4)				# On enregistre le caract�re courant dans la nouvelle chaine

	addi $t0, $t0, 1			# On passe au caract�re suivant dans la chaine
	lb $t1, ($t0)
	addi $t2, $t2, 1			# On passe au caract�re suivant dans la cl�
	lb $t3, ($t2)
	addi $t4, $t4, 1			# On passe au caract�re suivant dans la nouvelle chaine
	j boucle				# On revient au d�but de la cl�

# Ajout d'un espace dans la cl� r�p�t�e
ajout_espace:
	sb $t1, ($t4)
	addi $t0, $t0, 1
	lb $t1, ($t0)
	addi $t4, $t4, 1
	j boucle
	
# Routine de cryptage de chaine de caract�res
routine_cryptage:
	# Allocation et enregistrement de l'adresse de retour dans la pile
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	# On charge la chaine � crypter ainsi que la cl� r�p�t�e
	la $t0, chaine
	lb $t1, 0($t0)
	la $t4, chaine_cryptee
	la $t2, cle_repetee
	lb $t3, 0($t2)
	# D�but de la boucle de cryptage de la chaine
	crypte:
	beq $t1, 10, pas_modif			# Retour � l'appelant si on a atteint la fin de la chaine (10 = \n)
	beq $t1, 0, retour_appelant		# Retour � l'appelant si on a atteint la fin de la chaine (sans line feed) (0 = \0)
	beq $t1, 32, pas_modif			# On ne code pas les espaces
	add $t5, $t1, $t3			# Addition des deux caract�res courants : chaine + cl�
	div $t5, $t5, 26		
	mfhi $t5				# Modulo 26 pour revenir dans l'alphabet
	addi $t5, $t5, 65			# Ajout de 65 pour avoir une lettre entre A et Z
	sb $t5, ($t4)				# Stockage du caract�re dans la nouvelle chaine	
	jal car_suivant	
	j crypte				# Passage au caract�re suivant
	# Le caract�re "espace" est laiss� tel-quel
	pas_modif :
	sb $t1, ($t4)
	jal car_suivant
	j crypte
	
# Routine de d�cryptage de chaine de caract�res
routine_decryptage:
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	# On charge la chaine � d�crypter ainsi que la cl� r�p�t�e
	la $t0, chaine
	lb $t1, 0($t0)
	la $t4, chaine_decryptee
	la $t2, cle_repetee
	lb $t3, 0($t2)
	# D�but de la boucle de cryptage de la chaine
	decrypte:
	beq $t1, 10, retour_appelant		# Retour � l'appelant si on a atteint la fin de la chaine (10 = \n)
	beq $t1, 0, retour_appelant		# Retour � l'appelant si on a atteint la fin de la chaine (sans line feed) (0 = \0)
	beq $t1, 32, espaces
	sub $t5, $t1, $t3			# Soustraction des deux caract�res courants : chaine - cl�
	addi $t5, $t5, 26			# Ajout de 26 pour revenir � des nombres positifs
	div $t5, $t5, 26		
	mfhi $t5				# Modulo 26 pour revenir dans l'alphabet
	addi $t5, $t5, 65			# Ajout de 65 pour avoir une lettre entre A et Z
	sb $t5, ($t4)				# Stockage du caract�re dans la nouvelle chaine
	jal car_suivant	
	j decrypte				# Passage au caract�re suivant
	# Le caract�re "espace" est laiss� tel-quel
	espaces :
	sb $t1, ($t4)
	jal car_suivant
	j decrypte

# Passage au caract�re suivant
car_suivant:
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	addi $t2, $t2, 1
	lb $t3, 0($t2)
	addi $t4, $t4, 1
	j retour_appelant

# Permet de supprimer le caract�re '\n' � la fin du nom du fichier (pour pouvoir l'ouvrir)
nettoyer_nom_fichier:
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	li $t0, 0       #loop counter
	li $t1, 21      #loop end
nettoyage:
    	beq $t0, $t1, retour_appelant
    	lb $t3, fichier_entree($t0)
    	bne $t3, 0x0a, L6
    	sb $zero, fichier_entree($t0)
    	L6:
   	addi $t0, $t0, 1
	j nettoyage

# Retour � l'appelant
retour_appelant:
	lw $ra, 0($sp)				# R�cup�ration de l'adresse de retour
	addi $sp, $sp, 4			# Mot d�salou� sur la pile
	jr $ra					# Retour � l'appelant

# Demande � l'utilisateur si il veut continuer l'ex�cution du programme
continuer:
	li $v0, 50			 	# Service MIPS permettant d'afficher une fen�tre de dialogue
	la $a0, demande_continuer		# Message � afficher dans la fen�tre de dialogue 
	syscall
	move $t0, $a0				# R�cup�ration de la r�ponse de l'utilisateur : 0 - Oui, 1 - Non, 2 - Annuler
	beq $t0, 0, effacer_registres		# Si "Oui", retour au menu en remmetant � 0 les registres
	beq $t0, 1, exit			# Si "Non", on sort "proprement" du programme avec "exit"
	beq $t0, 2, continuer			# Sinon on r�affiche la fen�tre

# Sortir proprement du programme
exit:
	li $v0, 10				# Service MIPS permettant de mettre fin proprement au programme
	syscall
