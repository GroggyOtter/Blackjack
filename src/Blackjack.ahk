#Requires AutoHotkey v2.0.19+

*Esc::ExitApp()

*F1::Blackjack()

class Blackjack {
    static version => 1.0
    static current_player := ''
    static cards := this.generate_unicode_cards()
    static generate_unicode_cards() {
        deck := []
        unicode_card_start := 0x1F0A0
        loop 4 {
            i := unicode_card_start + (A_Index - 1) * 16
            loop 13
                if (A_Index < 12)
                    deck.Push(Chr(i + A_Index))
                else deck.Push(Chr(i + A_Index + 1))
        }
    }
    
    player := 0
    
    gui_bg_color := 0x404040
    
    __New() {
        Blackjack.Data.validate()                                                                   ; Verify ini is present
        if !Blackjack.current_player                                                                ; If not player is loaded
            Blackjack.Data.load_last_player()                                                       ;   Load the last one
        this.start_game()
    }
    
    start_game() {
        this.make_gui_start_menu()
    }
    
    make_gui_start_menu() {
        pad := 5
        pad2 := 10
        gw := 800
        gh := 600
        titleh := gh * 0.15
        titlew := gw - pad2
        title := 'AHK Blackjack'
        gr_h := gh * 0.5
        btn_w := 200
        btn_h := 50
        
        goo := Gui()
        goo.BackColor := this.gui_bg_color
        goo.MarginX := goo.MarginY := pad
        
        ; Title banner
        con := goo.AddText('xm ym w' titlew ' h' titleh ' Center BackgroundTrans', title)
        con.SetFont('bold italic s48 cBlack', 'ComicSans')
        con := goo.AddText('xp+3 yp+3 w' titlew ' h' titleh ' Center BackgroundTrans', title)
        con.SetFont('bold italic s48 cWhite', 'ComicSans')
        
        ; Card graphics
        ace := Chr(0x1F0A1)
        jack := Chr(0x1F0AB)
        con := goo.AddText('xm y+' pad2 ' w' gw ' h' gr_h ' center', ace jack)
        con.SetFont('s200')
        
        ; User controls
        goo.SetFont('s20')
        x := gw / 2 - btn_w / 2
        y := gh - (btn_h * 2 + pad2 * 3)
        con := goo.AddButton('x' x ' y' y ' w' btn_w ' h' btn_h, 'Play')
        con.OnEvent('Click', this.new_game.Bind(this))
        goo.AddButton('xp y+' pad2 ' w' btn_w ' h' btn_h, 'Load Player')
        goo.Show('w' gw ' h' gh)
        
        this.goo := goo
    }
    
    new_game(*) {
        if (this.goo is Gui && WinExist('ahk_id ' this.goo.hwnd))
            this.goo.Destroy()
        this.make_gui_new_game()
    }
    
    make_gui_new_game() {
        pad := 5
        pad2 := pad * 2
        padh := pad - 2
        gw := 800
        gh := 600
        
        title := 'AHK Blackjack'
        
        bet_btns := ['Clear', 'Max', '+1', '+10', '+100', '+1,000', '+10,000', '+100,000']
        bbtn_w := 80
        bbtn_h := 20
        gb_offset := 15
        gb_bet_h := bet_btns.Length * (bbtn_h + padh) + gb_offset + padh + pad
        gb_bet_w := bbtn_w + pad * 2
        
        player_btn := ['Hold', 'Hit', 'Double Down', 'Split']
        cbtn_w := 120
        cbtn_h := 40
        cbtn_buffer := 100
        btn_deal_w := player_btn.Length * (cbtn_w + pad) - pad
        btn_deal_h := cbtn_h
        
        goo := Gui()
        goo.BackColor := this.gui_bg_color
        
        ; Bet buttons
        ; Clear +1 +10 +100 +1,000 +10,000
        gb_y := gh - gb_bet_h - pad
        
        goo.SetFont('s10 cWhite')
        con := goo.AddGroupBox('xm y' gb_y ' w' gb_bet_w ' h' gb_bet_h ' Section Background101010', 'Bet Select')
        for btn_text in bet_btns {
            y := (A_Index - 1) * (bbtn_h + padh) + pad + gb_offset
            con := goo.AddButton('xs+' pad ' ys+' y ' w' bbtn_w ' h' bbtn_h, btn_text)
            con.SetFont('Bold')
            con.OnEvent('Click', this.make_bet.Bind(this))
        }
        
        ; User controls
        ; Hit, Stand, Double Down, Split, Insurance
        goo.SetFont('s12 Bold', 'Consolas')
        y_start := gh - pad2 - cbtn_h
        x_start := pad2 * 2 + gb_bet_w + cbtn_buffer
        for btn_text in player_btn {
            x := x_start + (A_Index - 1) * (cbtn_w + pad)
            con := goo.AddButton('x' x ' y' y_start ' w' cbtn_w ' h' cbtn_h ' Hidden', btn_text)
            con.Name := btn_text
            con.OnEvent('Click', this.player_action.Bind(this))
        }
        
        ; Deal button
        con := goo.AddButton('x' x_start ' y' y_start ' w' btn_deal_w ' h' btn_deal_h, 'Deal')
        con.OnEvent('Click', this.deal.Bind(this))
        
        goo.Show('w' gw ' h' gh)
    }
    
    deal(con, info) {
        MsgBox('deal cards code here')
    }
    
    player_action(control, player) {
        switch control.Text {
            case 'Hit': 
            case 'Stand': 
            case 'Double Down': 
            case 'Split': 
            default: throw Error('Invalid control type', A_ThisFunc, 'Control text: ' control.text)
        }
    }
    
    make_bet(btn, info) {
        MsgBox('User bet code here')
    }
    
    class Data {
        static save_dir => A_AppData '\AHK\Blackjack'
        static save_file_location => this.save_dir '\Data.ini'
        static new_save_file_text => '; AHK Blackjack Data File'
            . '`n; Created: ' A_Year '-' A_MM '-' A_DD '`n`n'
        
        static validate() {
            if !FileExist(this.save_dir)
                DirCreate(this.save_dir)
            if !FileExist(this.save_file_location)
                this.new_save_file()
        }
        
        /**
         * @param sec - The section (usually username)
         * No section defaults to _Settings
         * @param value - Value to be saved
         * @param key - Key to store the value
         * @returns Always returns an empty string
         */
        static save(key, value, sec:='_Settings') => IniWrite(
            value,
            this.save_file_location,
            sec,
            key
        )
        
        /**
         * @param sec - The section (usually username)
         * No section defaults to _Settings
         * @param key - Key to store the value
         * @returns {String} The requested value is always returned
         */
        static load(key, sec:='_Settings') => IniRead(this.save_file_location, sec, key, '')
        
        static load_player(name) {
            player := Blackjack.Player()
            for stat in player.stats
                player.stat := this.load(stat, player.name)
        }
        
        static save_player(player) {
            if !(player is Blackjack.Player)
                throw Error('Invalid player object.', A_ThisFunc)
            for stat in player.stats
                this.save(stat, player.%stat%, player.name)
        }
        
        static load_last_player() {
            name := this.load('last_player')
            if name
                this.load_player(name)
            else throw Error('No last player found!', A_ThisFunc)
        }
        
        static new_save_file() {
            FileAppend(this.new_save_file_text, this.save_file_location)
            this.save('last_player', '')
            Blackjack.current_player := Blackjack.Player()
            this.save('last_player', Blackjack.current_player.name)
        }
    }
    
    class Player {
        stats => ['Money', 'Win', 'Loss', 'Blackjacks', 'Pushes']
        
        __New(name?) {
            while !IsSet(name) {
                input := InputBox(
                    'Please enter your name.'
                    '`nName must be at least one character long.',
                    'Register New Player'
                )
                if (input.Result = 'OK' && StrLen(input.Value) > 0)
                    name := input.Value
            }
            
            this.name := name
            for stat in this.stats
                this.%stat% := 0
            
            Blackjack.Data.save_player(this)
        }
        
        save() => Blackjack.Data.save_player(this)
    }
    
    /**
     * card info:
     * suit - spade, heart
     * rank - ace, 7, king
     * number - 1, 7, 13
     * unicode - 0x1F0A1 = Ace of Spades
     * char - Glyph for unicode 0x1F0A1
     */
    class Deck {
        __New() {
            deck := []
            suits := ['Spade', 'Heart', 'Diamond', 'Club']
            suits := Map(
                'Spade'   ,0x2660,
                'Heart'   ,0x2661,
                'Diamond' ,0x2662,
                'Club'    ,0x2663
            )
            
            ranks := [
                'Ace'  ,'Two'   ,'Three' ,'Four' ,'Five',
                'Six'  ,'Seven' ,'Eight' ,'Nine' ,'Ten',
                'Jack' ,'Queen' ,'King'
            ]
            
            for suit_name, suit_uni in suits
                for rank_name in ranks
                    deck.Push(make_card(suit_name, suit_uni, A_Index, rank_name))
            
            return deck
            
            make_card(suit_name, suit_uni, rank_num, rank_name) {
                unicode_card_start := 0x1F0A0                                                       ; Start of unicode card glyphs
                skip_knight := rank_num > 12                                                        ; Skip knight b/c French deck
                unicode := unicode_card_start + rank_num + skip_knight + (suit_uni & 0xF) * 16      ; Calculate unicode
                card := {                                                                           ; Build card
                    suit: suit_name,                                                                ;   Suit word
                    suitico: Chr(suit_uni),                                                         ;   Suit glyph
                    number: rank_num,                                                               ;   Rank number
                    rank: rank_name,                                                                ;   Rank word
                    unicode: unicode,                                                               ;   Unicode number
                    char: Chr(unicode)                                                              ;   Unicode glyph
                }
                return card
            }
        }
    }
}

/* Player buttons:
Hit
    Draw another card
Stand
    End turn
Double Down
    One more card + double the bet
Split
    Pairs can be turned into two separate hands
    Deal extra card to each
    Allow double down with splits?
Insurance?
    Probably not gonna do this
    Insurance is a suckers bet anyway

/* Play order
The bet
Hand deal
    Dealer only shows 1 card
Blackjack check
First turn
    All actions available
        Hit
        Stand
        Double down
        Split pairs
Further turns
    Disabled
        Double Down
        Split
    Enabled
        Hit
        Stand


/* Ideas
Add a tutor mode that tells best play?  
Like if you hit on 17 it warns that you shouldn't?  
Card counting addition?

/* User data
Name
Money total
Wins
Losses
Blackjacks
