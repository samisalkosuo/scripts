#generate_username function.
#
#The MIT License (MIT)
#
#Copyright (c) 2017 Sami Salkosuo
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

import sys

def generate_username(formatStr,capitalize=False,title=False):
    """Generate random user name. formatStr is like CVC-CVC which generates username with consonant-vowel-consonant-consonant-vowel-consonant.

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
    if title==True:
        username= username.title()

    return username

for i in range(int(sys.argv[2])):
  print(generate_username(sys.argv[1]))
