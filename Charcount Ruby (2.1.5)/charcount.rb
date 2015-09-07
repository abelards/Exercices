# Récupération de la phrase passée en paramètre
phrase = ARGV.join(' ')
exit(1) if phrase.size == 0 # => exit(EXIT_FAILURE)

# Je veux une structure qui à un caractère (la clé) associe un chiffre (la valeur).
# C'est ce que font les Hash (avec les clés et valeurs que vous voulez).

# Il se trouve que je veux faire des additions sur la valeur, je vais soit coder
# "mets un 1 si je n'ai jamais vu ce caractère ou mets x + 1 si je trouve x",
# soit me dire "quand on accède à une clé, on lui met forcément zéro dedans"
# et `Hash.new {|cle_jamais_vue| valeur_a_donner }` fait exactement ça
chars = Hash.new { 0 }

# Et donc mon code est simple car au premier appel de `chars['x']`
# je n'ai pas `chars['x'] == nil` mais `chars['x'] == 0`
phrase.each_char { |c| chars[c] += 1 }

# Tri par caractère présent (les absents ne sont même pas dans la hash)
# `sort` prend en paramètre deux éléments et doit retourner -1 si a > b, +1 si b > a et 0 sinon
# Parcourir une hash {a: 1, b:2} la transformera en [[:a, 1], [:b, 2]]
# Du coup a et b sont des tableaux, `.first` pour la clé et `.last` pour la valeur
# (je trie par ordre alphabétique, mais en remplaçant `first` par `last` je trierais par fréquence)
puts chars.sort{|a,b| a.first <=> b.first }.map{|x|
  "Le caractère [#{x.first}] est utilisé #{x.last} fois"
}

# Pas de exit(0) car c'est ce qui se fait de toutes façons quand tout va bien
