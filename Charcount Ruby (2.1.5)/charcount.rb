#encoding: utf-8
#Initialisation du tableau de compte
charcount = Array.new(127,0)
#Préinitialisation des variable (pour que Ruby n'alloue pas ces variables à chaque tour de serviette)
i = 0
#Récupération de la phrase passé en argument
phrase = ARGV.join(' ')
exit(1) if phrase.bytesize == 0 #>exit(EXIT_FAILURE)
phrase.each_byte do |i|
  charcount[i] += 1 if i < 128
end
#Afficage des résultats
print("La phrase \"#{phrase}\" contient :\r\n")
charcount.each_index do |i|
  j = charcount[i]
  print("#{j} '#{i.chr}'\r\n") if j > 0
end
exit(0)