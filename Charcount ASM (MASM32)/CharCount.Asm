;---
; Version assembleur un peu casse t�te de l'exercice "Le compteur de caract�res"
; Ce fichier est libre
;---
.386
.model flat, stdcall
option casemap : none

;---
; Section d'inclusion et de d�claration de constantes/alias
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
	
	;R�cup�ration de la phrase
	call GetCommandLineA
	call get_argument
	mov sauvegarde_phrase, eax
	
	;Affichage de la phrase
	push eax
	push offset laphrase
	call _printf
	
	;Comptage des caract�res
	mov eax, sauvegarde_phrase
	call charcount
	
	exit(EXIT_SUCCESS)
	ret

_start endp

;---
; Fonction des d�sires : charcount qui va compter et afficher les caract�res utilis�s
;---
charcount Proc
	
	sub esp, ASCII_LEN ;On r�serve ce qu'il faut pour la table ASCII
	
	;On rempli notre table des compteur de caract�re de Z�ros
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
	
	;On compte les caract�res
	charcount_loop1:
	xor ecx, ecx
	mov cl, byte ptr [eax]
	test cl, 0FFh ; On v�rifie que c'est pas non null
	jz charcount_loop1_end
	
	inc eax ; On incr�mente eax pour �viter de tomber dans une boucle infinie
	test cl, 80h ; On �vite le d�bordement dans la table ASCII
	jnz charcount_loop1
	;On calcule le pointeur dans le tableau par rapport au caract�re
	shl ecx, 2
	mov edx, ebp
	sub edx, ecx
	inc dword ptr [edx] ;Le Z�ro n'arrive jamais :3
	jmp charcount_loop1
	charcount_loop1_end:
	
	;Affichage des r�sultats !
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
; Afficher le nombre d'utilisation d'un caract�re tout en pr�servant ecx et en se cassant pas la t�te avec ebp/esp
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
; Fonction qui permet de r�cup�rer le d�but de la phase, parce que MASM �crit des conneries avant l'entr�e du coup pas d'acc�s � argv � la mode de Linux :(
;---
get_argument Proc
	cmp byte ptr [eax], 22h ;V�rification du "path avec espaces/exe"
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
	inc eax ;L� on s'est arr�t� au " et non � ce qu'il y a apr�s donc on incr�mente :d
	
	;V�rification de la pr�sence de argv[1]
	get_argument_check_argv1:
	cmp byte ptr [eax], 00h
	je get_argument_no_argv1
	inc eax
	cmp byte ptr [eax], 20h ;argv[0] et argv[1] sont s�par�s de deux espaces avec GetCommandLine :p
	jne get_argument_no_argv1
	inc eax
	ret
	get_argument_no_argv1:
	exit(EXIT_FAILURE)
	ret

get_argument endp

end _start