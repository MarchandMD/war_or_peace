require 'spec_helper'

RSpec.describe 'iteration 2' do
  # cards
  let(:card1) { Card.new(:heart, 'Jack', 11) }
  let(:card2) { Card.new(:heart, '10', 10) }
  let(:card3) { Card.new(:heart, '9', 9) }
  let(:card4) { Card.new(:diamond, 'Jack', 11) }
  let(:card5) { Card.new(:heart, '8', 8) }
  let(:card6) { Card.new(:diamond, 'Queen', 12) }
  let(:card7) { Card.new(:heart, '3', 3) }
  let(:card8) { Card.new(:diamond, '2', 2) }

  describe '#init' do
    it 'exists' do
      player1 = Player.new('Megan', Deck.new([card1, card2, card3, card4]))
      player2 = Player.new('Aurora', Deck.new([card1, card2, card3, card4]))
      turn = Turn.new(player1, player2)
      expect(turn).to be_a(Turn)
    end

    it 'has @player1, @player2 and @spoils_of_war' do
      player1 = Player.new('Megan', Deck.new([card1, card2, card3, card4]))
      player2 = Player.new('Aurora', Deck.new([card1, card2, card3, card4]))
      turn = Turn.new(player1, player2)
      expect(turn).to have_attributes({ player1: player1, player2: player2, spoils_of_war: [] })
    end
  end

  context 'Turn :basic' do
    let(:deck1) { Deck.new([card1, card2, card5, card8]) }
    let(:deck2) { Deck.new([card3, card4, card6, card7]) }
    let(:player1) { Player.new('Megan', deck1) }
    let(:player2) { Player.new('Aurora', deck2) }
    let(:turn) {  Turn.new(player1, player2) }

    describe '#type' do
      it 'is :basic when card in first position has different ranks' do
        expect(turn.type).to eq(:basic)
      end
    end

    describe '#basic_turn?' do
      it 'can determine if both players 1st card matches rank' do
        expect(turn.basic_turn?).to be true
      end
    end

    describe '#winner' do
      it 'determines the winner' do
        expect(turn.type).to eq(:basic)
        expect(turn.winner.name).to eq('Megan')
      end
    end

    describe '#basic_turn_winner' do
      it 'returns player1 if player1 wins' do
        expect(turn.basic_turn_winner).to eq(player1)
      end
      it 'does not return player2 if player2 does not wins' do
        expect(turn.basic_turn_winner).not_to eq(player2)
      end

      it 'returns player1 if player1 wins' do
        player1 = Player.new('Megan', deck2)
        player2 = Player.new('Aurora', deck1)
        turn = Turn.new(player1, player2)
        expect(turn.basic_turn_winner).to eq(player2)
      end
    end

    describe '#pile_cards' do
      it 'pushes 2 cards to @spoils_of_war' do
        expect(turn.type).to eq(:basic)
        expect(turn.winner).to eq(player1)
        turn.pile_cards
        expect(turn.spoils_of_war.length).to eq(2)
      end
    end

    describe '#award_spoils' do
      it 'awards contents of @spoils_of_war to winner' do
        expect(turn.winner).to eq(player1)
        turn.pile_cards
        expect(turn.spoils_of_war.length).to eq(2)
        turn.award_spoils(player1)
        expect(player1.deck.cards.length).to eq(5)
      end
    end

    describe '#send_two_to_spoils' do
      it 'sends two cards to spoils of war' do
        turn.send_two_to_spoils
        expect(turn.spoils_of_war.length).to eq(2)
        expect(turn.player1.deck.cards.length).to eq(3)
        expect(turn.player2.deck.cards.length).to eq(3)
      end
    end
  end

  context 'Turn :war' do
    let(:deck3) { Deck.new([card1, card2, card7, card6]) }
    let(:deck4) { Deck.new([card4, card3, card6, card7]) }
    let(:player3) { Player.new('April', deck3) }
    let(:player4) { Player.new('Maddie', deck4) }
    let(:turn) { Turn.new(player3, player4) }

    describe '#war_turn?' do
      it 'can determine if :war' do
        expect(turn.war_turn?).to be true
      end
    end

    describe '#type' do
      it 'is :war when cards at 0 are the same' do
        turn = Turn.new(player3, player4)
        expect(turn.type).to eq(:war)
      end
    end

    describe '#winner' do
      it 'determines the winner' do
        turn = Turn.new(player3, player4)
        expect(turn.type).to eq(:war)
        expect(turn.winner).to eq(player4)
      end
    end

    describe '#war_turn_winner' do
      context "both players have at least 3 cards in deck" do
        it 'can identify the winner by observing cards at index[2]' do
          expect(player3.deck.cards.length).to be >= 3
          expect(player4.deck.cards.length).to be >= 3
          expect(turn.type).to eq(:war)
          expect(turn.winner).to eq(player4)
        end
      end

      context "player1 has < 3 cards in deck" do
        it 'returns player2 as the war_turn_winner' do
          player3.deck.cards.pop(3)
          expect(turn.war_turn_winner).to eq(player4)
        end
      end

      context "player2 has < 3 cards in deck" do
        it 'returns player1 as the war_turn_winner' do
          player4.deck.cards.pop(3)
          expect(turn.war_turn_winner).to eq(player3)
        end
      end

      it 'returns player1 when player1 wins' do
        expect(turn.war_turn_winner).to eq(player4)
      end
    end

    describe '#compare_card_at_second_position' do
      context "player2 has a higher card in index[2]" do
        it 'returns player2' do
          expect(turn.compare_card_at_second_position).to eq(player4)
        end
      end

      context "player1 has a higher card in index[2]" do
        it 'returns player1' do
          player3 = Player.new('April', deck4)
          player4 = Player.new('Maddie', deck3)
          turn = Turn.new(player3, player4)
          expect(turn.compare_card_at_second_position).to eq(player3)
        end

      end

    end

    describe '#pile_cards' do
      it 'puts 6 card in @spoils_of_war' do
        turn.pile_cards
        expect(turn.spoils_of_war.length).to eq(6)
      end

      
    end

    describe '#send_six_to_spoils' do
      it 'moves three cards from each player to @spoils_of_war' do
        turn.send_six_to_spoils
        expect(turn.spoils_of_war.length).to eq(6)
      end
    end

    describe '#award_spoils' do
      it 'awards contents of spoils_of_war to winner' do
        turn.pile_cards
        expect(turn.spoils_of_war.length).to eq(6)
        turn.award_spoils(turn.winner)
        expect(turn.player1.deck.cards.length).to eq(7)
        expect(turn.spoils_of_war).to eq([])
      end
    end
  end

  context 'Turn :mutually_assured_destruction' do
    let(:card1) { Card.new(:heart, 'Jack', 11) }
    let(:card2) { Card.new(:heart, '10', 10) }
    let(:card3) { Card.new(:heart, '9', 9) }
    let(:card4) { Card.new(:diamond, 'Jack', 11) }
    let(:card5) { Card.new(:heart, '8', 8) }
    let(:card6) { Card.new(:diamond, '8', 8) }
    let(:card7) { Card.new(:heart, '3', 3) }
    let(:card8) { Card.new(:diamond, '2', 2) }
    let(:deck1) { Deck.new([card1, card2, card5, card8]) }
    let(:deck2) { Deck.new([card4, card3, card6, card7]) }
    let(:player1) { Player.new('Megan', deck1) }
    let(:player2) { Player.new('Aurora', deck2) }
    let(:turn) { Turn.new(player1, player2) }

    describe '#type' do
      it 'is :mutually_assured_destruction when cards at 0 and 2 are the same' do
        expect(turn.type).to eq(:mutually_assured_destruction)
      end
    end

    describe '#pile_cards' do
      it 'removes the first three cards from each player' do
        turn.pile_cards
        expect(player1.deck.cards.count).to eq(1)
        expect(player2.deck.cards.length).to eq(1)
      end
    end

    describe '#winner' do
      it "returns string 'No Winner'" do
        expect(turn.winner).to eq('No Winner')
        expect(turn.type).to eq(:mutually_assured_destruction)
      end
    end

    describe '#m_a_d?' do
      it 'determines if 1st and 3rd cards match in rank' do
        deck1 = Deck.new([card1, card2, card3, card4])
        deck2 = Deck.new([card1, card2, card3, card4])
        player1 = Player.new('Megan', deck1)
        player2 = Player.new('Aurora', deck2)
        turn = Turn.new(player1, player2)
        expect(turn.m_a_d_turn?).to be true
        deck1 = Deck.new([card1, card2, card2, card4])
        deck2 = Deck.new([card1, card2, card3, card4])
        player1 = Player.new('Megan', deck1)
        player2 = Player.new('Aurora', deck2)
        turn = Turn.new(player1, player2)
        expect(turn.m_a_d_turn?).to be false
      end
    end

    describe '#remove_six_cards' do
      it 'removes 3 cards from each players deck' do
        deck1 = Deck.new([card1, card2, card3, card4])
        deck2 = Deck.new([card1, card2, card3, card4])
        player1 = Player.new('Megan', deck1)
        player2 = Player.new('Aurora', deck2)
        turn = Turn.new(player1, player2)
        turn.remove_six_cards
        expect(turn.player1.deck.cards.length).to eq(1)
        expect(turn.player2.deck.cards.length).to eq(1)
      end
    end

    describe '#spoils_of_war' do
      it 'remains empty' do
        expect(turn.spoils_of_war).to eq([])
      end
    end
  end

  context 'final turn' do
    let(:deck1) { Deck.new([]) }
    let(:deck2) { Deck.new([card3, card4, card6, card7]) }
    let(:player1) { Player.new('Megan', deck1) }
    let(:player2) { Player.new('Aurora', deck2) }
    let(:turn) { Turn.new(player1, player2) }

    describe '#init' do
      it 'can start with a player with no cards' do
        expect(turn.player1.deck.cards.length).to eq(0)
      end
    end

    describe '#card_count_over_three?' do
      it 'can determine if either player has less than 3 cards' do
        deck1 = Deck.new([card1, card2, card3, card4])
        deck2 = Deck.new([card1, card2, card3, card4])
        player1 = Player.new('Megan', deck1)
        player2 = Player.new('Aurora', deck2)
        turn = Turn.new(player1, player2)
        expect(turn.card_count_over_three?).to be true
        player1.deck.cards = []
        expect(turn.card_count_over_three?).to be false
      end
    end

    describe '#card_count_under_three?' do
      it 'can determine if a player has less than 3 cards' do
        expect(turn.card_count_under_three?).to be true
      end
    end
  end
end
