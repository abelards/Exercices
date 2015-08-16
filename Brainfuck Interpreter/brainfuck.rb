#encoding: utf-8
#====
#¤ Brainfuck_Interpreter
#---
#  Utilisation : 
#  ruby brainfuck.rb "code"
#-
#  ruby brainfuck.rb filename
#-
#  require "brainfuck"
#  interpreter = Brainfuck_Interpreter.new(code) #word_size = taille en octet des mots de la mémoire, memory_size = taille de la mémoire (optionnel)
#  interpreter.start
#---
#  Dépendances : STDIN et STDOUT, si vous êtes en mode fenêtré, faites usage de IO#reopen
#---
#  Informations :
#  Cet interpréteur a été pensé de la manière suivante :
#    On lit directement tous les caractères du code comme des instructions (un peu de la même manière qu'un processeur)
#    Si les caractères sont dans le jeu d'instruction (Assoc) ils invoquent l'une des méthodes qui leur est associé, sinon, ils sont ignorés
#    Chaque instruction peut agir sur la mémoire (+ -), le pointeur (> <) ou "l'index du lecteur d'instruction" (toutes)
#    Ruby se charge intérieurement de faire le switch / case pour interpréter les instructions
#===
class Brainfuck_Interpreter
  #===
  #> Tableau associatif des instructions de brainfuck aux méthodes de l'interpreter
  #  Tout ce qui n'est pas dans ce tableau est ignoré
  #===
  Assoc = {'>' => :ptr_inc, '<' => :ptr_dec, '+' => :value_inc, '-' => :value_dec, '.' => :write_value, ',' => :read_value, '[' => :loop_begin, ']' => :loop_end}
  #===
  #> Initialisation de l'interpreter
  #  On enregistre le code et les propriétés de l'interpreter
  #===
  def initialize(code, word_size = 1, memory_size = 30_000)
    if(word_size < 1)
      print("Erreur, la taille des mots ne peut pas être inférieur à 1 (#{word_size})\r\n")
      word_size = 1
    end
    if(memory_size < 30_000)
      print("Erreur, la taille de la mémoire ne peut pas être inférieur à 30 000 mots\r\n")
      memory_size = 30_000
    end
    @code = code
    @index = nil
    @ptr = nil
    @mask = 2**(8*word_size) - 1
    @memory_size = memory_size
  end
  #===
  #>Démarrage de l'interpreter
  # Un programme peut être réexcuté plusieurs fois mais pas de manière parallèle (il faudra démarrer un autre interpreter)
  #===
  def start
    return if(@index||@ptr)
    @index = 0
    @ptr = 0
    @loop_begins = Array.new
    @memory =  Array.new(@memory_size, 0)
    sz = @code.size
    while @index < sz #@index and 
      v = Assoc[@code[@index]]
      if v
        @index = send(v)
      else
        @index += 1
      end
    end
    @index = nil
    @ptr = nil
  end
  private
  #===
  #> Incrément du pointeur
  #  Retourne à zéro si il dépasse la mémoire
  #===
  def ptr_inc
    @ptr += 1
    @ptr = 0 if @ptr >= @memory_size
    @index.next
  end
  #===
  #> Décrément du pointeur
  #  Retourne à la fin si il tombe dans le négatif
  #===
  def ptr_dec
    @ptr -= 1
    @ptr += @memory.size if @ptr < 0
    @index.next
  end
  #===
  #> Incrément de la valeur pointé
  #===
  def value_inc
    @memory[@ptr] = (@memory[@ptr]+1)&@mask
    @index.next
  end
  #===
  #> Décrément de la valeur pointé
  #===
  def value_dec
    @memory[@ptr] = (@memory[@ptr]-1)&@mask
    @index.next
  end
  #===
  #> Ecriture de la valeur dans le flux de sortie
  #===
  def write_value
    if(@mask == 255)
      STDOUT << @memory[@ptr].chr
    else
      v = @memory[@ptr]
      while(v > 0)
        STDOUT << (v&255).chr
        v >>= 8
      end
    end
    @index.next
  end
  #===
  #> Lecture d'un octet dans le flux d'entrée
  #===
  def read_value
    v = STDIN.getc.getbyte(0)
    v = 0 if v == 10 #>Saut de ligne à la fin d'un input. Est-ce correct ? Faut-il considérer que le précédent était 10 et écrire 0 ?
    @memory[@ptr] = v
    @index.next
  end
  #===
  #> Entrée dans une boucle (ou sortie)
  #===
  def loop_begin
    if(@memory[@ptr] != 0)
      @loop_begins << @index
      @index.next
    else
      find_end_off_loop
    end
  end
  #===
  #> Retour en début de boucle
  #===
  def loop_end
    @loop_begins.pop
  end
  #===
  #> Recherche de la fin réelle de la boucle
  #  On compte le nombre d'ouverture et de fermeture, les fermetures décrémentent les ouvertures incrémentent et normalement si le compteur est à 0 on a trouvé la vrai fin
  #====
  def find_end_off_loop
    _index = @index
    nb = 1
    v = 0
    while(nb > 0)
      _index += 1
      case @code.getbyte(_index)
      when 91
        nb += 1
      when 93
        nb -= 1
      when nil
        raise RuntimeError, "Failed to find ]"
      end
    end
    _index.next
  end
end
#====
#> Gestion du démarrage par ruby de manière directe ou non
#  Normalement si il y a require, caller.size > 0
#  Si il n'y a pas require caller.size == 0
#===
if(caller.size == 0)
  if(ARGV.size == 0)
    print("Usage : \r\nruby brainfuck.rb \"code\"\r\nruby brainfuck.rb filename\r\n")
  else
    arg = ARGV[0]
    ext = File.extname(arg)
    if(ext == ".bf" || ext == ".b")
      File.open(arg,"rb") do |f|
        Brainfuck_Interpreter.new(f.read(f.size)).start
      end
    else
      Brainfuck_Interpreter.new(arg).start
    end
  end
end