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

#UseHook
#WinActivateForce

; F? -------------------------------------

; Windows key
; F18State := "Off" ; Off | Tapping | Pressing
; F18 & a::Right
; ~*F18::
;   If (F18State = "Off") {
;       F18State := "Tapping"
;       KeyWait, F19, T0.2
;       If (ErrorLevel) {
;         F18State := "Pressing"
;       } Else {
;         Send {RWin Down}{F3}{RWin Up}
;       }
;       F18State := "Off"
;   }
; Return

F19State := "Off" ; Off | Tapping | Pressing
; �g�ݍ��킹
F19 & a::Right
~*F19::
  If (F19State = "Off") {
      F19State := "Tapping"
      KeyWait, F19, T0.2
      If (ErrorLevel) {
        F19State := "Pressing"
      } Else {
        If (IME_GET() = 0) {
          IME_SET(1)
        } Else {
          IME_SET(0)
        }
      }
      F19State := "Off"
  }
Return

; Game Settings
F21::
  key1 := "A"
  key2 := "W"
	Send {%key1% Down}{%key2% Down}
	keywait, F21
  Send {%key1% Up}{%key2% Up}
Return

F22::
  key1 := "W"
  key2 := "D"
	Send {%key1% Down}{%key2% Down}
	keywait, F22
  Send {%key1% Up}{%key2% Up}
Return

F23::
  key1 := "S"
  key2 := "D"
	Send {%key1% Down}{%key2% Down}
	keywait, F23
  Send {%key1% Up}{%key2% Up}
Return

F24::
  key1 := "A"
  key2 := "S"
	Send {%key1% Down}{%key2% Down}
	keywait, F24
  Send {%key1% Up}{%key2% Up}
Return


; #F? -------------------------------------
#F1::Send {Ctrl down}{Shift down}{Tab}{Ctrl up}{Shift up}

#F2::Send {Ctrl down}{Tab}{Ctrl up}

; Convert kana
#F4::
if IME_GET() = 0
	; Send, ^+{Left}
	Send, ^{x}
	ClipWait
  RegExMatch(%Clipboard%, "([a-zA-Z0-9]+)$", %Clipboard%)
  ClipWait
  IME_SET(1)
	Send, %Clipboard%
  IME_SET(0)
Return

#F5::Send, {Media_Play_Pause}

; Convert eisu
#F6::
if IME_GET() = 1
  Send, {F10}
  Send, {Enter}
Return

; Clipboard custome
#F7::
  Clipboard = ?��?��?��͂悤?��?��?��?��?��?��?��܂�?��I`n - %Clipboard%?��?��?��?��
	ClipWait

; IME change ei
#F9::
if IME_GET() = 1
  IME_SET(0)
Return

; Convert kana
#F10::
if IME_GET() = 0
  IME_SET(1)
Return

; Change IME
; F13 Up::
; if (A_PriorKey = "F13") {
;   if IME_GetConverting() >= 1 {
;     Return
;   }
;   if IME_GET() = 0
;     IME_SET(1)
;   else
;     IME_SET(0)
; }
; Return

; switch IME
/*
PutSwitchIME:
  IME_SET(0)
return
$RShift::
  if A_TickCount < %EscDouble%
  {
    SetTimer, PutSwitchIME, OFF
    EscDouble = 0
    IME_SET(1)
    return
  }
  else
  {
    EscDouble = %A_TickCount%
    EscDouble += 100
    SetTimer, PutSwitchIME, -100
  }
  KeyWait, RShift
return

; switch IME2
~RShift::
key := "RShift"
KeyWait, %key%, T0.3
KeyWait, %key%, D, T0.2
  If(!ErrorLevel){
      if (IME_GET() = 0) IME_SET(1)
      KeyWait, %key%
      return
  }else{
      if (IME_GET() = 1) IME_SET(0)
      KeyWait, %key%
      return
  }
*/

; Fn+Shift+Right -------------------------------------
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

; Other -------------------------------------
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

; Win default
~RShift::Send {RWin Down}{F3}{RWin Up}

; single LWin powertoys run
; ~LWin::Send {RWin Down}{F3}{RWin Up}

; brave active
; ~RShift::
;   WinActivate, ahk_exe brave.exe
; Return

; Send key based on double click -------------------------------------
SendKeyBasedOnDoubleClick(key, singleClickKey, doubleClickKey) {
  KeyWait, %key%, T0.3  ; ?��L?��[?��?��0.3?��b?��ȓ�?��ɕ�?��?��?��?��?��̂�҂�
  KeyWait, %key%, D T0.2  ; ?��L?��[?��?��?��ēx?��?��?��?��?��?��?��̂�0.2?��b?��ȓ�?��ɑ҂�
  if (ErrorLevel) {  ; ErrorLevel?��?��?��?��0?��̏ꍇ?��A?��^?��C?��?��?��A?��E?��g?��i?��V?��?��?��O?��?��?��N?��?��?��b?��N?��j
      Send %singleClickKey%
  } else {  ; ?��^?��C?��?��?��A?��E?��g?��łȂ�?���??��i?��_?��u?��?��?��N?��?��?��b?��N?��j
      Send %doubleClickKey%
  }
Return
}
; Win
; ~LWin::SendKeyBasedOnDoubleClick("LWin", "{#F3}", "{RShift}")

; ~RShift:: ; ?��E?��V?��t?��g?��L?��[?��?��?��?��?��?��?��ꂽ?��Ƃ�?��Ɏ�?��s
  ; WinGet, active_id, ID, A
  ; WinGet, active_exe, ProcessName, ahk_id %active_id%

  ; MsgBox, The active window's ID is "%active_id%" , "%active_exe%".

  ; windows := [] ; ?��E?��B?��?��?��h?��EID?��?��?��i?��[?��?��?��?��z?��?��?��?��?��?��?��?��?��
  ; WinGet, id_list, List, ahk_exe %active_exe% ; ?��?��?��?��?��?��?��s?��t?��@?��C?��?��?��?��?��?��?��?��?��E?��B?��?��?��h?��E?���??��?��X?��g?��?��?��擾
  ; Loop, %id_list%
  ;   {
  ;   this_id := id_list[A_Index] ; ?��?��?��݂̃E?��B?��?��?��h?��EID?��?��?��擾
  ;   windows.Push(this_id) ; ?��z?��?��ɃE?��B?��?��?��h?��EID?��?��ǉ�
  ;   }
  ; {
  ;   this_id := id_list[A_Index] ; ?��?��?��݂̃E?��B?��?��?��h?��EID?��?��?��擾
  ;   windows.Push(this_id) ; ?��z?��?��ɃE?��B?��?��?��h?��EID?��?��ǉ�
  ; }
  ; MsgBox, Value Is: "%active_id% %active_exe% %windows% %id_list%"
  ; ; ?��?��?��݃A?��N?��e?��B?��u?��ȃE?��B?��?��?��h?��E?��̃C?��?��?��f?��b?��N?��X?��?��z?��?��猟?��?��
  ; currentIndex := windows.IndexOf(active_id)
  ; If (currentIndex = -1 || currentIndex = windows.Length() - 1) ; ?��?��?��?��?��?��?��݂̃E?��B?��?��?��h?��E?��?��?��?��?��X?��g?��̍Ō�A?��܂�?��͌�?���?��?��Ȃ�?��?��?��?��?��?��
  ; {
  ;   nextIndex := 1 ; ?��ŏ�?��̃E?��B?��?��?��h?��E?��ɖ߂�
  ; }
  ; Else
  ; {
  ;   nextIndex := currentIndex + 2 ; ?��?��?��̃E?��B?��?��?��h?��E?��̃C?��?��?��f?��b?��N?��X?��i1?��x?��[?��X?��̃C?��?��?��f?��b?��N?��X?��Ȃ̂�+2?��j
  ; }
  ; WinActivate, ahk_id windows[nextIndex] ; ?��?��?��̃E?��B?��?��?��h?��E?��?��?��A?��N?��e?��B?��u?��?��
;   WinGet, active_id, ID, A
;   WinGet, active_exe, ProcessName, ahk_id %active_id%

;   windows := []
;   WinGet, id_list, List, ahk_exe %active_exe%
;   msssage := ""
;   Loop, %id_list%
;     {
;       this_id := id_list%A_Index%
;       windows.Push(this_id)
;       ; MsgBox, this_id: "%this_id%"
;       ; msssage := %message% . %this_id%
;       ; msssage := "a" . "b"
;     }
;   maxindex := windows.MaxIndex()
;   currentIndex := windows["%active_id%"].IndexOf
;   ; If (currentIndex = -1 || currentIndex = windows.Length() - 1)
;   ; {
;   ;   nextIndex := 1
;   ; }
;   ; Else
;   ; {
;   ;   nextIndex := currentIndex + 2
;   ; }
;   ; WinActivate, ahk_id windows[nextIndex]
;   nextIndex := 0
;   for index, id in windows
;   {
;     MsgBox, id : "%id%", index : "%index%"
;     if (id = active_id)
;     {
;       nextIndex := index + 1
;       if (nextIndex > maxindex)
;       {
;         nextIndex := 1
;       }
;       break
;     }
;   }
;   ; MsgBox, The active window's ID is "%active_id%" , "%active_exe%" , "%windows%" , "%id_list%" , "%maxindex%", "%currentIndex%".
;   ; MsgBox % "change id:" . windows[nextIndex]
;   a := windows[nextIndex]
;   ; msssage = %message% . %this_id%
;   ; MsgBox, "%message%"
;   WinActivate, ahk_id %a%
; Return

; Windows?��L?��[?��?��?��?��?��?��?��ꂽ?��?��?��ǂ�?��?��?��?��ǐՂ�?��?��t?��?��?��O
; SinglePress(lastkey, sendkey) {
;   KeyWait, %lastkey%
;   if (A_PriorKey = %lastkey%)
;   {
;     Send %sendkey%
;   }
;   return
; }

; LWin:: SinglePress("LWin", "a")

; SinglePress(lastkey, sendkey) {
;   KeyWait, %lastkey%, D
;   If (A_PriorKey = lastkey)
;   {
;       Send %sendkey%
;   }
;   else
;   {
;     Send {LWin}
;   }
;   return
; }

; LWin:: SinglePress("LWin", "{a}")

; LWinIsPressed := false
; ; LWin?��L?��[?��?��?��?��?��?��?��ꂽ?��Ƃ�?��̏�?��?��
; ~LWin::
; {
;   ; ?��t?��?��?��O?��?��ݒ�
;   LWinIsPressed := true
;   ; A?��L?��[?��?��?��?��?��?��?��?��?��?��Ԃɂ�?��?��
;   Send("{LWin down}")
; }
; ; LWin?��L?��[?��?��?��?��?��?��?��ꂽ?��Ƃ�?��̏�?��?��
; ~LWin up::
; {
;   ; ?��t?��?��?��O?��?��?��?��?��Z?��b?��g
;   LWinIsPressed := false
;   ; A?��L?��[?��?���
;   Send("{LWin up}")
;   Send {RWin Down}{F3}{RWin Up}
; }
; ; ?��?��?��̃L?��[?��?��?��?��?��?��?��ꂽ?��Ƃ�?��̏�?��?��
; ~*LWin &::
; {
;   ; LWin?��L?��[?��?��?��?��?��?��?��?��Ă�?��?���??��ɂ̓t?��?��?��O?��?��?��?��?��Z?��b?��g?��?��?��?��A?��L?��[?��?���
;   if (LWinIsPressed) {
;     LWinIsPressed := false
;     ; Send("{a up}")
;     Send("{LWin up}")
;   }
; }

; ?��^?��C?��}?��[?��?��?��I?��?��?��?��?��?��?��Ƃ�?��Ƀt?��?��?��O?��?��?��m?��F?��?��?��āA?��K?��v?��Ȃ�΁ub?��v?��?��M
; CheckShift:
;   if !GetKeyState("Shift", "P") {
;     ; Shift?��L?��[?��?��?��?��?��?��?��?��Ă�?��Ȃ�?���??��A?��ub?��v?��?��M
;     Send {b}
;   }
;   return

; ShiftIsPressed := false
; ; Shift?��L?��[?��?��?��?��?��?��?��ꂽ?��Ƃ�?��̏�?��?��
; ~Shift::
; {
;   ; ?��t?��?��?��O?��?��ݒ�
;   ShiftIsPressed := true
;   ; Shift?��L?��[?��?��?��?��?��?��?��?��?��?��Ԃɂ�?��?��
;   Send {Shift down}
;   ; 200ms?��ҋ@?��?��?��āA?��P?��̉�?��?��?��?��?��m?��F
;   SetTimer, CheckShift, -200
; }
; ; Shift?��L?��[?��?��?��?��?��?��?��ꂽ?��Ƃ�?��̏�?��?��
; ~Shift up::
; {
;   ; ?��t?��?��?��O?��?��?��?��?��Z?��b?��g
;   ShiftIsPressed := false
;   ; Shift?��L?��[?��?���
;   Send {Shift up}
; }
