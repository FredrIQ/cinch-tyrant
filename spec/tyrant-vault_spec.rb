require_relative 'test-common'

require 'cinch/plugins/tyrant-vault'

describe Cinch::Plugins::TyrantVault do
  include Cinch::Test

  let(:bot) {
    make_bot(Cinch::Plugins::TyrantVault, {:checker => 'testplayer'}) { |c|
      self.loggers.stub('debug') { nil }
    }
  }

  it 'makes a test bot' do
    expect(bot).to be_a Cinch::Bot
  end

  describe '!vault' do
    let(:message) { make_message(bot, '!vault', channel: '#test') }

    before :each do
      @conn = FakeConnection.new
      @tyrant = Tyrants.get_fake('testplayer', @conn)
      expect(Tyrants).to receive(:get).with('testplayer').and_return(@tyrant)
    end

    it 'shows vault cards' do
      bot.plugins[0].stub(:shared).and_return({:cards_by_id => {
        1 => FakeCard.new(1, 'My first card'),
        2 => FakeCard.new(2, 'Another awesome card'),
      }})
      @conn.respond('getMarketInfo', '', {
        'cards_for_sale' => ['1', '2'],
        'cards_for_sale_starting' => Time.now.to_i,
      })
      replies = get_replies_text(message)
      expect(replies.shift).to be =~
        /^\[VAULT\] My first card, Another awesome card\. Available for \d\d:\d\d:\d\d$/
      expect(replies).to be == []
    end
  end

  # TODO: revault?!
end
