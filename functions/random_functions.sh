#random functions

function randomNumber()
{
  #env variable name passed to this function
  local  __rv=${1:-}
  local __elementArray=(0 1 2 3 4 5 6 7 8 9)
  local __count=${#__elementArray[*]}
  local  __randomElement=${__elementArray[$((RANDOM%__count))]}

  if [[ "$__rv" ]]; then
      eval $__rv="'$__randomElement'"
  else
      echo "$__randomElement"
  fi
}

function randomConsonant()
{
  #env variable name passed to this function
  local  __rv=${1:-}
  local __elementArray=(q w r t p l k j h g f d s z x c v b n m)
  local __count=${#__elementArray[*]}
  local  __randomElement=${__elementArray[$((RANDOM%__count))]}

  if [[ "$__rv" ]]; then
      eval $__rv="'$__randomElement'"
  else
      echo "$__randomElement"
  fi
}

function randomVowel()
{
  #env variable name passed to this function
  local  __rv=${1:-}
  local __elementArray=(a o i u y e)
  local __count=${#__elementArray[*]}
  local  __randomElement=${__elementArray[$((RANDOM%__count))]}

  if [[ "$__rv" ]]; then
      eval $__rv="'$__randomElement'"
  else
      echo "$__randomElement"
  fi
}