import sys

def generate_username(formatStr,capitalize=False):
    """Generate random user name. formatStr is like CVC-CVC which generates username with consonant-vowel-consonant-consonant-vowel-consonant.abs

    C=consonant
    V=vowel
    N=number
    +=space
    """
    import random
    import re

    vowels="eyuioa"
    consonants="mnbvcxzlkjhgfdsptrwq"
    numbers="0123456789"

    def randomVowel():
        return random.choice(vowels)

    def randomConsonant():
        return random.choice(consonants)

    def randomNumber():
        return random.choice(numbers)

    regex = re.compile('[^a-zA-Z+]')
    formatStr=regex.sub('', formatStr)
    username=[]
    for c in formatStr.upper():
        if c=="C":
          username.append(randomConsonant())
        if c=="V":
          username.append(randomVowel())
        if c=="+":
          username.append(" ")
        if c=="N":
          username.append(randomNumber())
    username="".join(username)
    if capitalize==True:
        username= username.capitalize()

    return username

for i in range(int(sys.argv[2])):
  print(generate_username(sys.argv[1]))
