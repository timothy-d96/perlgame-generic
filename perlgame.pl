#!/usr/bin/perl

use SDL::Event;
use SDL::Video;
use SDL::Mouse;
use SDL::Rect;
use SDLx::App;
use SDLx::Controller;

my $app = SDLx::App->new(
    title => "perlgame-generic",
    #Change width, height and flags for desired resolution. (16x9 strongly recommended)
    #DEFAULT 0
        width => 1024,
        height => 576,
    #DEFAULT 1
        #width => 1920,
        #height => 1080,
        #flags => SDL_NOFRAME,
);

###########################################################################################################

SDL::Mouse::show_cursor(SDL_DISABLE);
char();
maps();
$currentroom = '100';
$previousroom = '100';
$drawpreviousroom = 0;
$roomsd = 0;
$roomsvel = ($app->w)/16;
$moveplayer = 1;

$app->add_event_handler( \&event_handle );
$app->add_move_handler( \&on_move );
$app->add_show_handler( \&on_show );
$app->run();

sub event_handle {
    my $e = shift;
    if ( $e->type == SDL_KEYDOWN ) {
        my $key = $e->key_sym;
        $char[0]{y_vel} -= $char[0]{vel} if $key == SDLK_w;
        $char[0]{y_vel} += $char[0]{vel} if $key == SDLK_s;
        $char[0]{x_vel} -= $char[0]{vel} if $key == SDLK_a;
        $char[0]{x_vel} += $char[0]{vel} if $key == SDLK_d;
    } elsif ( $e->type == SDL_KEYUP ) {
        my $key = $e->key_sym;
        $char[0]{y_vel} += $char[0]{vel} if $key == SDLK_w;
        $char[0]{y_vel} -= $char[0]{vel} if $key == SDLK_s;
        $char[0]{x_vel} += $char[0]{vel} if $key == SDLK_a;
        $char[0]{x_vel} -= $char[0]{vel} if $key == SDLK_d;
    } elsif ( $e->type == SDL_QUIT ) {
        $_[0]->stop;
    }
}

sub on_move {
    my $dt = shift;

    #corners of player character
    #x,y    x+w,y
    #x,y+h  x+w,y+h

    #center of character int (x+(w/2))/w, int (y+(h/2))/h

    #PLAYER MOVEMENT
    if ( $moveplayer ) {
        for ( my $i = 0; $i < abs( $char[0]{x_vel} * $dt ); $i++ ) {
            if ( $char[0]{x_vel} > 0 ) { #move right (x+w,y x+w,y+h)
                if ( substr($maps{$currentroom}[int( ( $char[0]{y} ) / $char[0]{h} )], int( ( $char[0]{x}+1 + $char[0]{w} ) / $char[0]{w} ), 1) ne 'E' and
                substr($maps{$currentroom}[int( ( $char[0]{y} + $char[0]{h} ) / $char[0]{h} )], int( ( $char[0]{x}+1 + $char[0]{w} ) / $char[0]{w} ), 1) ne 'E' ) {
                    $char[0]{x}++;
                }
            } elsif ( $char[0]{x_vel} < 0 ) { #move left (x,y x,y+h)
                if ( substr($maps{$currentroom}[int( ( $char[0]{y} ) / $char[0]{h} )], int( ( $char[0]{x}-1 ) / $char[0]{w} ), 1) ne 'E' and
                substr($maps{$currentroom}[int( ( $char[0]{y} + $char[0]{h} ) / $char[0]{h} )], int( ( $char[0]{x}-1 ) / $char[0]{w} ), 1) ne 'E' ) {
                    $char[0]{x}--;
                }
            }
        }
        for ( my $i = 0; $i < abs( $char[0]{y_vel} * $dt ); $i++ ) {
            if ( $char[0]{y_vel} > 0 ) { #move down (x,y+h x+w,y+h)
                if ( substr($maps{$currentroom}[int( ( $char[0]{y}+1 + $char[0]{h} ) / $char[0]{h} )], int( ( $char[0]{x} ) / $char[0]{w} ), 1) ne 'E' and
                substr($maps{$currentroom}[int( ( $char[0]{y}+1 + $char[0]{h} ) / $char[0]{h} )], int( ( $char[0]{x} + $char[0]{w} ) / $char[0]{w} ), 1) ne 'E' ) {
                    $char[0]{y}++;
                }
            } elsif ( $char[0]{y_vel} < 0 ) { #move up (x,y x+w,y)
                if ( substr($maps{$currentroom}[int( ( $char[0]{y}-1 ) / $char[0]{h} )], int( ( $char[0]{x} ) / $char[0]{w} ), 1) ne 'E' and
                substr($maps{$currentroom}[int( ( $char[0]{y}-1 ) / $char[0]{h} )], int( ( $char[0]{x} + $char[0]{w} ) / $char[0]{w} ), 1) ne 'E' ) {
                    $char[0]{y}--;
                }            
            }
        }
    } else {
        for ( my $i = 0; $i < abs( $roomsvel * $dt ); $i++ ) {
            if ( $roomsd eq 'n' and $pryoffset < $app->h ) {
                $char[0]{y} = 16*$char[0]{h};
                $pryoffset++;
            } elsif ( $roomsd eq 's' and $pryoffset > 0 ) {
                $char[0]{y} = $char[0]{h};
                $pryoffset--;
            } elsif ( $roomsd eq 'w' and $prxoffset < $app->w ) {
                $char[0]{x} = 30*$char[0]{w};
                $prxoffset += 2;
            } elsif ( $roomsd eq 'e' and $prxoffset > 0 ) {
                $char[0]{x} = $char[0]{w};
                $prxoffset -= 2;
            } else {
                $moveplayer = 1;
                $drawpreviousroom = 0;
            }
        }
    }
    if ( substr($maps{$currentroom}[int( ( $char[0]{y} + $char[0]{h} ) / $char[0]{h} )], int( ( $char[0]{x} ) / $char[0]{w} ), 1) eq 'n' ) { newroom('n'); }
    if ( substr($maps{$currentroom}[int( ( $char[0]{y} ) / $char[0]{h} )], int( ( $char[0]{x} ) / $char[0]{w} ), 1) eq 's' ) { newroom('s'); }
    if ( substr($maps{$currentroom}[int( ( $char[0]{y} ) / $char[0]{h} )], int( ( $char[0]{x} + $char[0]{w} ) / $char[0]{w} ), 1) eq 'w' ) { newroom('w'); }
    if ( substr($maps{$currentroom}[int( ( $char[0]{y} ) / $char[0]{h} )], int( ( $char[0]{x} ) / $char[0]{w} ), 1) eq 'e' ) { newroom('e'); }
}
sub newroom {
    $previousroom = $currentroom;
    $moveplayer = 0;
    $drawpreviousroom = 1;
    if ($_[0] eq 'n') {
        $currentroom--;
        $prxoffset = 0;
        $pryoffset = 0;
        $roomsd = 'n';
    }
    #WRONG
    if ($_[0] eq 's') {
        $currentroom++;
        $prxoffset = 0;
        $pryoffset = $app->h;
        $roomsd = 's';
    }
    if ($_[0] eq 'w') {
        $currentroom -= 100;
        $prxoffset = 0;
        $pryoffset = 0;
        $roomsd = 'w';
    }
    #WRONG
    if ($_[0] eq 'e') {
        $currentroom += 100;
        $prxoffset = $app->w;
        $pryoffset = 0;
        $roomsd = 'e';
    }
}

sub on_show {
    #clear screen
    SDL::Video::fill_rect(
        $app,
        SDL::Rect->new( 0, 0, $app->w, $app->h ),
        SDL::Video::map_RGB( $app->format, 0, 0, 0)
    );
    #draw previous room
    if ( $drawpreviousroom ) {
        for ( my $i = 0; $i < 32; $i++ ) {
            for ( my $j = 0; $j < 18; $j++ ) {
                if ( substr($maps{$previousroom}[$j], $i, 1) eq 'E' ) {
                    SDL::Video::fill_rect(
                        $app,
                        SDL::Rect->new( ($i*($app->w/32))+$prxoffset, ($j*($app->h/18))+$pryoffset, (($app->w)/32)+$prxoffset, (($app->h)/18)+$pryoffset ),
                        SDL::Video::map_RGB( $app->format, 100, 100, 100)
                    );
                }
            }
        }
    }
    #draw current room
    for ( my $i = 0; $i < 32; $i++ ) {
        for ( my $j = 0; $j < 18; $j++ ) {
            if ( substr($maps{$currentroom}[$j], $i, 1) eq 'E' ) {
                SDL::Video::fill_rect(
                    $app,
                    SDL::Rect->new( ($i*($app->w/32)), ($j*($app->h/18)), (($app->w)/32), (($app->h)/18) ),
                    SDL::Video::map_RGB( $app->format, 255, 255, 255)
                );
            }
        }
    }
    #draw characters
    SDL::Video::fill_rect(
        $app,
        SDL::Rect->new( $char[0]{x}, $char[0]{y}, $char[0]{w}, $char[0]{h} ),
        SDL::Video::map_RGB( $app->format, 0, 0, 255)
    );
    $app->sync;
}

###########################################################################################################

#Characters (Array of Hashes)
sub char {
    @char = (
        #Player Character
        {
            x => 100,
            y => 100,
            w => ($app->w)/32,
            h => ($app->h)/18,
            vel => ($app->w)/32,
            x_vel => 0,
            y_vel => 0,
        },
    );
}

#Maps (Hash of Arrays)
sub maps {
    %maps = (
        #ROOM 00-01-00
        100 => [
            "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E                              e",
            "E                              e",
            "E                              e",
            "E                              e",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "EEEEEEEEEEEEEEEEEEEEEEssssEEEEEE",
        ],
        #ROOM 00-02-00
        200 => [
            "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "w                              E",
            "w                              E",
            "w                              E",
            "w                              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
        ],
        #ROOM 00-00-01
        1 => [
            "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E                              e",
            "E                              e",
            "E                              e",
            "E                              e",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
        ],
        #ROOM 00-01-01
        101 => [
            "EEEEEEEEEEEEEEEEEEEEEEnnnnEEEEEE",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "w                              E",
            "w                              E",
            "w                              E",
            "w                              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "E              EE              E",
            "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
        ],
    );
}