module Downloaders
  class BgoData
    class << self
      NAME_TRANSFORMS = {
        "1066, Tears To Many Mothers" => "1066, Tears to Many Mothers: The Battle of Hastings",
        "1824: Austrian-Hungarian Railway (Second Edition)" => "1824: Austrian-Hungarian Railway",
        "Abalone Classic" => "Abalone",
        "Axis & Allies Europe 1940" => "Axis & Allies: Europe 1940",
        "Axis & Allies Pacific 1940" => "Axis & Allies: Pacific 1940",
        "Ca$h 'n Guns (Second Edition)" => "Ca$h 'n Guns: Second Edition",
        "Caesar!: Seize Rome in 20 minutes" => "Caesar!: Seize Rome in 20 Minutes!",
        "Castle Itter" => "Castle Itter: The Strangest Battle of WWII",
        "Codenames: Disney Family Edition" => "Codenames: Disney – Family Edition",
        "Combat!" => "Combat! Volume 1",
        "DC Comics Deck-Building Game" => "DC Deck-Building Game",
        "DC Comics Deck-Building Game: Forever Evil" => "DC Deck-Building Game: Forever Evil",
        "DC Comics Deck-Building Game: Rivals – Batman vs The Joker" => "DC Deck-Building Game: Rivals – Batman vs The Joker",
        "DC Comics Deck-Building Game: Teen Titans" => "DC Deck-Building Game: Teen Titans",
        "Diamant" => "Incan Gold",
        "Disney Villainous" => "Disney Villainous: The Worst Takes it All",
        "Dungeons & Dragons: Waterdeep – Dungeon of the Mad Mage" => "Dungeons & Dragons: Waterdeep – Dungeon of the Mad Mage Board Game",
        "Expedition: Northwest Passage" => "Expedition: Northwest Passage – HMS Terror Edition",
        "Extraordinary Adventures: Pirates" => "Extraordinary Adventures: Pirates!",
        "For the King and Me" => "For the King (and Me)",
        "GROVE: A 9 card solitaire game" => "Grove: 9 card solitaire game",
        "Hamsterrolle" => "Hamster Roll",
        "Hapsburg Eclipse" => "Hapsburg Eclipse: The Great War in Eastern Europe 1914-1916",
        "Haspelknecht" => "Haspelknecht: The Story of Early Coal Mining",
        "Here I Stand (500th Anniversary Reprint Edition)" => "Here I Stand: 500th Anniversary Edition",
        "Julius Caesar" => "Julius Caesar: Caesar, Pompey, and the Roman Civil War",
        "Linko!" => "Linko",
        "Love Letter: Infinity Gauntlet" => "Infinity Gauntlet: A Love Letter Game",
        "Mission: Red Planet (Second Edition)" => "Mission: Red Planet (Second/Third Edition)",
        "On the Underground: London/Berlin" => "On the Underground: London / Berlin",
        "One Night Ultimate Werewolf Daybreak" => "One Night Ultimate Werewolf: Daybreak",
        "Pandemic: Fall of Rome" => "Fall of Rome",
        "Pandemic: Reign of Cthulhu" => "Reign of Cthulhu",
        "Pharaoh's Gulo Gulo" => "Gulo Gulo",
        "Q.E." => "QE",
        "Runebound (Second Edition)" => "Runebound: Second Edition",
        "Sheriff of Nottingham (2nd Edition)" => "Sheriff of Nottingham: 2nd Edition",
        "Shinkansen: Zero Kei" => "Shinkansen: Zero-Kei",
        "Space Empires: 4X" => "Space Empires 4X",
        "Stronghold (2nd edition)" => "Stronghold: 2nd edition",
        "Talisman (Revised 4th Edition)" => "Talisman: Revised 4th Edition",
        "Taluva Deluxe" => "Taluva",
        "That's Pretty Clever" => "That's Pretty Clever!",
        "The Lamps Are Going Out" => "The Lamps are Going Out: World War I",
        "The Red Dragon Inn 5" => "The Red Dragon Inn 5: The Character Trove",
        "Tumblin-Dice" => "Tumblin' Dice",
        "Ubongo 3-D" => "Ubongo 3D",
        "Unforgiven" => "Unforgiven: The Lincoln Assassination Trial",
        "Unlock!: Kids" => "Unlock! Kids: Detective Stories",
        "Vinhos Deluxe Edition" => "Vinhos: Deluxe Edition",
        "Zombicide (2nd Edition)" => "Zombicide: 2nd Edition",
        "Zombies!!! 4: The End..." => "Zombies!!!",
      }

      def price_for(game)
        bgo_game = games.find { |g| normalize_name(g.name.to_s).downcase == game.name.downcase }
        return unless bgo_game

        bgo_game.the_price
      end

      def unmatched_names(bgg_games)
        games.select do |bgo_game|
          bgg_games.none? do |bgg_game|
            normalize_name(bgo_game.name.to_s).downcase == bgg_game.name.downcase
          end
        end
      end

      def games
        @games ||= File
          .read("./bgo_data.txt")
          .split("\n\n")
          .map { |data| build_game(data) }
      end

      private

      def normalize_name(name)
        NAME_TRANSFORMS.fetch(name, name)
      end

      def build_game(data)
        p1, _, p3, p4, play_time, rating, weight = data.split("\n")
        price = p3.split("$").last.to_f
        rating = rating.to_f
        weight = weight.to_f
        name, year, offer_count = p1.scan(/(.*)(\d{4}) • (\d+) offer/).first
        year = year.to_i
        offer_count = offer_count.to_i
        if p4.include?(" - ")
          min_player_count, max_player_count = p4.split(" - ").map(&:to_i)
        else
          min_player_count = p4.to_i
          max_player_count = p4.to_i
        end
        Game.new(
          rating:,
          weight:,
          name:,
          year:,
          offer_count:,
          min_player_count:,
          max_player_count:,
          the_price: price,
        )
      end
    end
  end
end
