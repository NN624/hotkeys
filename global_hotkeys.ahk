;----------------
; README
; UTF-8
; LF
;----------------


;---------------------------------------------------------------------------
;  汎用関数 (多分どのIMEでもいけるはず)

;-----------------------------------------------------------
; IMEの状態の取得
;   WinTitle="A"    対象Window
;   戻り値          1:ON / 0:OFF
;-----------------------------------------------------------
IME_GET(WinTitle="A")  {
    ControlGet,hwnd,HWND,,,%WinTitle%
    if    (WinActive(WinTitle))    {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
        NumPut(cbSize, stGTI,  0, "UInt")   ;    DWORD   cbSize;
        hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
                 ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
    }

    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          ,  Int, 0x0005  ;wParam  : IMC_GETOPENSTATUS
          ,  Int, 0)      ;lParam  : 0
}

;-----------------------------------------------------------
; IMEの状態をセット
;   SetSts          1:ON / 0:OFF
;   WinTitle="A"    対象Window
;   戻り値          0:成功 / 0以外:失敗
;-----------------------------------------------------------
IME_SET(SetSts, WinTitle="A")    {
    ControlGet,hwnd,HWND,,,%WinTitle%
    if    (WinActive(WinTitle))    {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
        NumPut(cbSize, stGTI,  0, "UInt")   ;    DWORD   cbSize;
        hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
                 ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
    }

    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          ,  Int, 0x006   ;wParam  : IMC_SETOPENSTATUS
          ,  Int, SetSts) ;lParam  : 0 or 1
}

;----------------------------------------
; IMEの状態を切り替え
;----------------------------------------
IME_CHANGE()    {
    return IME_SET(!IME_GET())
}

#UseHook
#WinActivateForce

; 【F?】 -------------------------------------
; F18 key map
; F18 & j::Send {BackSpace}
; F18 & k::Send {Enter}
; F18::
;   F18State := "Off" ; Off | Tapping | Pressing
;   If (F18State = "Off") {
;     F18State := "Tapping"
;     KeyWait, F18, T0.2
;     If (ErrorLevel) {
;       F18State := "Pressing"
;     } Else {
;       Send {Click} ; single click
;     }
;     F18State := "Off"
;   }
; Return

; F19 key map
F19 & d::Send {BackSpace}
F19 & f::Send {Enter}
F19::
  F19State := "Off" ; Off | Tapping | Pressing
  If (F19State = "Off") {
      F19State := "Tapping"
      KeyWait, F19, T0.2
      If (ErrorLevel) {
        F19State := "Pressing"
      } Else {
        IME_CHANGE() ; single click
      }
      F19State := "Off"
  }
Return

; 【#F?】 -------------------------------------
; Switch previous tab
#F1::Send {Ctrl down}{Shift down}{Tab}{Ctrl up}{Shift up}

; Switch next tab
#F2::Send {Ctrl down}{Tab}{Ctrl up}

; Play pause media
#F5::Send, {Media_Play_Pause}

; Convert eisu
#F6::
if IME_GET() = 1
  Send, {F10}
  Send, {Enter}
Return

; 【Fn+Shift+Right】 -------------------------------------
; fn up down left right
<!Up::Send {PgUp}
<^<!Up::Send ^{PgUp}
<!+Up::Send +{PgUp}
<^<!+Up::Send ^+{PgUp}

<!Down::Send {PgDn}
<^<!Down::Send ^{PgDn}
<!+Down::Send +{PgDn}
<^<!+Down::Send ^+{PgDn}

<!Left::Send {Home}
<^<!Left::Send ^{Home}
<!+Left::Send +{Home}
<^<!+Left::Send ^+{Home}

<!Right::Send {End}
<^<!Right::Send ^{End}
<!+Right::Send +{End}
<^<!+Right::Send ^+{End}

; 【Other】 -------------------------------------
; Switch window
~RWin::
  key := "RWin"
  Send {Alt Down}{Tab}
  While True{
    KeyWait, %key%, U
    KeyWait, %key%, D T0.5 ; windowを切り替えるために0.5秒待つ
    If (ErrorLevel=0){
      Send {Tab}
    }
    Else{
      Send {Alt Up}
      Break
    }
  }
Return