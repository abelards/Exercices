# Interpreter Brainfuck
## Mise en garde
Le programmeur de cet interpréteur ne connait rien à la programmation. Mais cela ne l'empêche pas de programmer des choses par pur plaisir.
Si vous n'êtes pas d'accord sur la manière de procéder du "programme", dites-le mais soyez constructifs et évitez la condescendance. (Le programmeur n'est pas un programmeur C++ même si il en a l'air.)
Le programmeur est un mur quand on ne lui sort pas des arguments valides et correctement exprimés.
## Informations
  Cet interpreteur a été pensé de la manière suivante :
    On lit directement tous les caractères du code comme des instructions (un peu de la même manière qu'un processeur)
    Si les caractères sont dans le jeu d'instruction (Assoc) ils invoquent l'une des méthodes qui leur est associé, sinon, ils sont ignorés
    Chaque instruction peut agir sur la mémoire (+ -), le pointeur (> <) ou "l'index du lecteur d'instruction" (toutes)
    Ruby se charge intérieurement de faire le switch / case pour interpréter les instructions
## Utilisation
### Executer un code court
`ruby brainfuck.rb "code"`
### Executer un code contenu dans un fichier
`ruby brainfuck.rb filename`
L'extension .b ou .bf est requise.
### Utilisation dans un programme Ruby
```
require "brainfuck"
interpreter = Brainfuck_Interpreter.new(code) #word_size = taille en octet des mots de la mémoire, memory_size = taille de la mémoire (optionnel)
interpreter.start
```