"""A Simple Magic Quest Game"""

import random;
import from byllm.llm { Model }

glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=False);

"""Give a magical hint for the treasure guess"""
def magic_hint(guess: int, correct: int) -> str by llm();

"""Create a short riddle"""
def create_riddle(theme: str) -> str by llm();

# Simple fallback functions (used when LLM fails)
def simple_hint(guess: int, correct: int) -> str {
    if guess < correct {
        return f"🔮 The crystal glows dimly... the magic number is HIGHER than {guess}!";
    } else {
        return f"🔮 The crystal dims... the magic number is LOWER than {guess}!";
    }
}

def simple_riddle() -> str {
    riddles = [
        "I brighten the day but vanish at night, what am I?",
        "I dance without feet and sing without voice, what am I?", 
        "I'm hot and bright, dragons breathe me, what am I?"
    ];
    return riddles[random.randint(0, len(riddles) - 1)];
}

walker Hero {
    has name: str;
    has score: int = 0;
    
    can start with `root entry;
    can play_game with quest entry;
}

node quest {
    has treasure_number: int = random.randint(1, 10);
    has riddle_answer: str = "";
    has completed: bool = False;
}

with entry:__main__ {
    print("🧙‍♂️ Welcome to Magic Quest!");
    name = input("Enter your hero name: ") or "Hero";
    root spawn Hero(name=name);
}

impl Hero.start {
    print(f"✨ Welcome😊,  {self.name}! Find the magic treasure!");
    quest_node = root ++> quest();
    visit quest_node;
}

impl Hero.play_game {
    if here.completed {
        print(f"🎉 Quest complete! Final score: {self.score}");
        disengage;
    }
    
    print(f"--- {self.name}'s Quest (Score: {self.score}) ---");
    print("1. Guess treasure number (1-10)");
    print("2. Solve magic riddle");
    print("3. Quit");
    
    choice = input("Choose: ");
    
    if choice == "1" {
        guess_input = input("🔮 Guess the magic number: ");
        
        # Check if input is a valid number
        if not guess_input.isdigit() {
            print("❌ Please enter a valid number!");
            visit here;
            return;
        }
        
        guess = int(guess_input);
        
        if guess == here.treasure_number {
            print("💎 Found the treasure! +10 points!");
            self.score += 10;
            here.treasure_number = random.randint(1, 10);  # New treasure
        } else {
            # Use simple hint directly since LLM has authentication issues
            print("⚠️ LLM unavailable, using simple hints");
            hint = simple_hint(guess, here.treasure_number);
            print(f"{hint}");
        }
    } elif choice == "2" {
        if not here.riddle_answer {
            # Use simple riddle directly since LLM has authentication issues
            print("⚠️ LLM unavailable, using simple riddle");
            riddle = simple_riddle();
            
            print(f"🧩 Riddle: {riddle}");
            answer = input("Answer: ").lower();
            here.riddle_answer = answer;
            
            if "light" in answer or "fire" in answer or "sun" in answer or "flame" in answer {
                print("✅ Correct! +5 points!");
                self.score += 5;
            } else {
                print("❌ Wrong answer, but +1 for trying!");
                self.score += 1;
            }
        } else {
            print("🧩 You already solved the riddle!");
        }
    } elif choice == "3" {
        here.completed = True;
    } else {
        print("❌ Invalid choice! Please choose 1, 2, or 3.");
    }
    
    if self.score >= 20 {
        print("🏆 You've become a Master Wizard!");
        here.completed = True;
    }

    visit here;
}