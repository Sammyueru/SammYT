// ==----------------------------------------==
//    shared/inc/utils/gui/imgui/misc
//    (c) Samm, SEE LICENSE FILE
// ==----------------------------------------==

#define IMGUI_DEFINE_MATH_OPERATORS
#include "misc.h"
#include <imgui/imgui.h>
#include <imgui/imgui_internal.h>

void ImGui::ProgressIndicatorBar(uint8_t percent, ImVec2 fullsize, ImColor progress_col=IM_COL32(0, 12, 192, 255))
{
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    ImVec2 cursor = window->DC.CursorPos;

    int progress_dpercent = fullsize.x / percent;

    window->DrawList->AddRectFilled(
        cursor + ImVec2(0, 0),
        cursor + fullsize,
        IM_COL32(0,0,0,255)
    );

    window->DrawList->AddRectFilled(
        cursor + ImVec2(0, 0),
        cursor + ImVec2(progress_dpercent, fullsize.y),
        progress_col
    );
}
