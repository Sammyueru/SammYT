// ==----------------------------------------==
//    Useless float compression
//    [PROJECT] START DATE: 1/6/2024
//    (c) Samm, SEE LICENSE.txt FILE
// ==----------------------------------------==
#include <iostream>
#include <SDL2/SDL.h>

int main(int argc, char* argv[])
{
    if(!SDL_Init(SDL_INIT_EVENTS | SDL_INIT_VIDEO | SDL_INIT_TIMER))
    {
        return -1;
    }

    SDL_Window* window = SDL_CreateWindow("Useless float compression", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, SDL_WINDOW_ALLOW_HIGHDPI);
    if(window == NULL)
    {
        return -1;
    }

    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if(renderer == NULL)
    {
        return -1;
    }

    uint8_t running = 1;
    while(running)
    {


        SDL_Delay(16);
    }

    return 0;
}
