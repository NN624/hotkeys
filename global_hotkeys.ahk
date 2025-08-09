;----------------
; README
; UTF-8
; LF
;----------------

#Requires AutoHotkey v2.0+

;-----------------------------------------------------------
; IMEの状態をセット
;   SetSts          1:ON / 0:OFF
;   WinTitle="A"    対象Window
;   戻り値          0:成功 / 0以外:失敗
;-----------------------------------------------------------
IME_SET(SetSts, WinTitle:="A")    {
    hwnd := WinExist(WinTitle)
    if  (WinActive(WinTitle))   {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        cbSize := 4+4+(PtrSize*6)+16
        stGTI := Buffer(cbSize,0)
        NumPut("Uint", cbSize, stGTI.Ptr,0)   ;   DWORD   cbSize;
        hwnd := DllCall("GetGUIThreadInfo", "Uint",0, "Uint",stGTI.Ptr)
        ? NumGet(stGTI.Ptr,8+PtrSize,"Uint") : hwnd
    }
    return DllCall("SendMessage"
            , "UInt", DllCall("imm32\ImmGetDefaultIMEWnd", "Uint",hwnd)
            , "UInt", 0x0283  ;Message : WM_IME_CONTROL
            ,  "Int", 0x006   ;wParam  : IMC_SETOPENSTATUS
            ,  "Int", SetSts) ;lParam  : 0 or 1
}

;-----------------------------------------------------------
; IMEの状態の取得
;   WinTitle="A"    対象Window
;   戻り値          1:ON / 0:OFF
;-----------------------------------------------------------
IME_GET(WinTitle:="A")  {
    hwnd := WinExist(WinTitle)
    if  (WinActive(WinTitle))   {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        cbSize := 4+4+(PtrSize*6)+16
        stGTI := Buffer(cbSize,0)
        NumPut("DWORD", cbSize, stGTI.Ptr,0)   ;   DWORD   cbSize;
        hwnd := DllCall("GetGUIThreadInfo", "Uint",0, "Uint", stGTI.Ptr)
        ? NumGet(stGTI.Ptr,8+PtrSize,"Uint") : hwnd
    }
    return DllCall("SendMessage"
            , "UInt", DllCall("imm32\ImmGetDefaultIMEWnd", "Uint",hwnd)
            , "UInt", 0x0283  ;Message : WM_IME_CONTROL
            ,  "Int", 0x0005  ;wParam  : IMC_GETOPENSTATUS
            ,  "Int", 0)      ;lParam  : 0
}

; Play pause media
#F5::Send "{Media_Play_Pause}"

; previous tab
F19 & l:: Send "{Ctrl down}{Shift down}{Tab}{Ctrl up}{Shift up}"
; next tab
F19 & k:: Send "{Ctrl down}{Tab}{Ctrl up}"

; previous page
F19 & j:: Send "{Alt down}{Left}{Alt up}"
; next page
F19 & vkBA:: Send "{Alt down}{Right}{Alt up}"

; Change IME state
F18::IME_SET(0)
F19::IME_SET(1)

; convert to eisu
F19 & a::{
if IME_GET() = 1
    Send "{F10}"
    Send "{Enter}"
return
}

; 【Fn+Shift+Right】 -------------------------------------
; fn up down left right
<!Up::Send "{PgUp}"
<^<!Up::Send "^{PgUp}"
<!+Up::Send "+{PgUp}"
<^<!+Up::Send "^+{PgUp}"

<!Down::Send "{PgDn}"
<^<!Down::Send "^{PgDn}"
<!+Down::Send "+{PgDn}"
<^<!+Down::Send "^+{PgDn}"

<!Left::Send "{Home}"
<^<!Left::Send "^{Home}"
<!+Left::Send "+{Home}"
<^<!+Left::Send "^+{Home}"

<!Right::Send "{End}"
<^<!Right::Send "^{End}"
<!+Right::Send "+{End}"
<^<!+Right::Send "^+{End}"