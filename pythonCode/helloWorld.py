import random
print("hello world")

n = random.randint(0,100)
check = False

while (check == False):

    value = input("Enter num 1-100:")
    if value == n:
    
        print("You got it!")
        check = True
    
    else:
        
        print("Nope")
    
