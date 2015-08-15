;---
; Version assembleur un peu casse tête de l'exercice "Le compteur de caractères"
; Ce fichier est libre
;---
.386
.model flat, stdcall
option casemap : none

;---
; Section d'inclusion et de déclaration de constantes/alias
;---
include \masm32\include\masm32rt.inc
_printf equ crt_printf
ASCII_LEN equ 200h

;---
; Section Data
;---
.data
laphrase db "La phrase ", 22h, "%s", 22h, " contient :", 13, 10, 0
lecaract db "%d '%c'", 13, 10, 0

;---
; Section Code
;---
.code
_start Proc 
	
	LOCAL sauvegarde_phrase
	
	;Récupération de la phrase
	call GetCommandLineA
	call get_argument
	mov sauvegarde_phrase, eax
	
	;Affichage de la phrase
	push eax
	push offset laphrase
	call _printf
	
	;Comptage des caractères
	mov eax, sauvegarde_phrase
	call charcount
	
	exit(EXIT_SUCCESS)
	ret

_start endp

;---
; Fonction des désires : charcount qui va compter et afficher les caractères utilisés
;---
charcount Proc
	
	sub esp, ASCII_LEN ;On réserve ce qu'il faut pour la table ASCII
	
	;On rempli notre table des compteur de caractère de Zéros
	xor ecx, ecx
	charcount_loop0:
	add ecx, 4
	cmp ecx, ASCII_LEN
	je charcount_loop0_end
	mov edx, ebp
	sub edx, ecx
	mov dword ptr [edx], 0
	jmp charcount_loop0
	charcount_loop0_end:
	
	;On compte les caractères
	charcount_loop1:
	xor ecx, ecx
	mov cl, byte ptr [eax]
	test cl, 0FFh ; On vérifie que c'est pas non null
	jz charcount_loop1_end
	
	inc eax ; On incrémente eax pour éviter de tomber dans une boucle infinie
	test cl, 80h ; On évite le débordement dans la table ASCII
	jnz charcount_loop1
	;On calcule le pointeur dans le tableau par rapport au caractère
	shl ecx, 2
	mov edx, ebp
	sub edx, ecx
	inc dword ptr [edx] ;Le Zéro n'arrive jamais :3
	jmp charcount_loop1
	charcount_loop1_end:
	
	;Affichage des résultats !
	xor ecx, ecx
	charcount_loop2:
	add ecx, 4
	cmp ecx, ASCII_LEN
	je charcount_loop2_end
	mov edx, ebp
	sub edx, ecx
	mov eax, dword ptr [edx]
	test eax, -1
	jz charcount_loop2
	call afficher_char
	jmp charcount_loop2
	charcount_loop2_end:
	
	;FIN !
	leave
	ret

charcount endp

;---
; Afficher le nombre d'utilisation d'un caractère tout en préservant ecx et en se cassant pas la tête avec ebp/esp
;---
afficher_char Proc
	
	LOCAL _ecx
	mov _ecx, ecx
	shr ecx, 2
	push ecx
	push eax
	push offset lecaract
	call _printf
	mov ecx, _ecx
	ret

afficher_char endp

;---
; Fonction qui permet de récupérer le début de la phase, parce que MASM écrit des conneries avant l'entrée du coup pas d'accès à argv à la mode de Linux :(
;---
get_argument Proc
	cmp byte ptr [eax], 22h ;Vérification du "path avec espaces/exe"
	je get_argument_quote
	
	;Recherche de la fin de argv[0] sans "quote"
	get_argument_normal:
	inc eax
	test byte ptr [eax], 0DFh
	jnz get_argument_normal
	jmp get_argument_check_argv1
	
	;Recherche de la fin de argv[0] avec une "quote"
	get_argument_quote:
	inc eax
	cmp byte ptr [eax], 22h
	jne get_argument_quote
	inc eax ;Là on s'est arrêté au " et non à ce qu'il y a après donc on incrémente :d
	
	;Vérification de la présence de argv[1]
	get_argument_check_argv1:
	cmp byte ptr [eax], 00h
	je get_argument_no_argv1
	inc eax
	cmp byte ptr [eax], 20h ;argv[0] et argv[1] sont séparés de deux espaces avec GetCommandLine :p
	jne get_argument_no_argv1
	inc eax
	ret
	get_argument_no_argv1:
	exit(EXIT_FAILURE)
	ret

get_argument endp

end _start