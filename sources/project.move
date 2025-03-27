module 0xf0605b287d62794e1ed0cbbfd57dc0a228abaee21124e9b5766a4e02f1a88b0c::DailyQuiz {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::option;

    struct Quiz has store, key {
        correct_answer: u8, // Store the correct answer (e.g., 1, 2, 3, 4)
        winner: option::Option<address>, // Track the winner
    }

    /// Initialize the quiz with a correct answer.
    public fun initialize_quiz(admin: &signer, correct_answer: u8) {
        let quiz = Quiz {
            correct_answer,
            winner: option::none<address>(),
        };
        move_to(admin, quiz);
    }

    /// Submit an answer for the daily quiz.
    public fun submit_answer(user: &signer, answer: u8) acquires Quiz {
        let quiz = borrow_global_mut<Quiz>(signer::address_of(user));
        if (answer == quiz.correct_answer) {
            quiz.winner = option::some(signer::address_of(user));
        }
    }

    /// Reward the winner with Aptos tokens.
    public fun reward_winner(admin: &signer, amount: u64) acquires Quiz {
        let quiz = borrow_global_mut<Quiz>(signer::address_of(admin));
        assert!(option::is_some(&quiz.winner), 1); // Ensure there's a winner

        // Correct way to extract the winner's address
        let winner_addr = option::get_with_default(&quiz.winner, @0x0); // Default to 0x0 if no winner
        
        let reward = coin::withdraw<AptosCoin>(admin, amount);
        coin::deposit<AptosCoin>(winner_addr, reward);
    }
}

