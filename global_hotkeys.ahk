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
#F6::Send "!{Left}"
#F7::Send "!{Right}"
#F8::{
    Send "{Alt down}{tab}"
    Send "{Alt up}"
return
}


F19::Send "{Alt down}{``}{Alt up}"

; convert to eisu
F19 & a::{
if IME_GET() = 1
    Send "{F10}"
    Send "{Enter}"
return
}

; convert to kana
; F19 & s:: {
;     ; 一時的にクリップボードを保存
;     ClipSaved := A_Clipboard
;     A_Clipboard := ""

;     ; 選択中の文字をコピー
;     Send("^c")
;     if !ClipWait(0.5) {
;         A_Clipboard := ClipSaved
;         return
;     }

;     InputText := A_Clipboard
;     A_Clipboard := ClipSaved

;     ; 選択範囲を削除
;     Send("{Backspace}")

;     ; 日本語入力モードをONにする
;     IME_SET(1)

;     ; 少し待ってから再入力
;     Sleep(200)
;     for char in StrSplit(InputText)
;         SendInput(char)
; }

F19 & n::Send "{Volume_Down}"
F19 & m::Send "{Volume_Up}"
F19 & ,::Send "{Media_Play_Pause}"

; Alt + 矢印キーによるページナビゲーション設定
; <!    = 左Alt
; <^    = 左Ctrl
; +     = Shift

; [Alt + 上下左右] ------------
; Alt + 上下 = Page Up/Down
<!Up::Send "{PgUp}"           ; Alt + ↑ = Page Up
<^<!Up::Send "^{PgUp}"       ; Ctrl + Alt + ↑ = Ctrl + Page Up
<!+Up::Send "+{PgUp}"        ; Alt + Shift + ↑ = Shift + Page Up
<^<!+Up::Send "^+{PgUp}"     ; Ctrl + Alt + Shift + ↑ = Ctrl + Shift + Page Up

<!Down::Send "{PgDn}"        ; Alt + ↓ = Page Down
<^<!Down::Send "^{PgDn}"     ; Ctrl + Alt + ↓ = Ctrl + Page Down
<!+Down::Send "+{PgDn}"      ; Alt + Shift + ↓ = Shift + Page Down
<^<!+Down::Send "^+{PgDn}"   ; Ctrl + Alt + Shift + ↓ = Ctrl + Shift + Page Down

; Alt + 左右 = Home/End
<!Left::Send "{Home}"         ; Alt + ← = Home（行頭へ）
<^<!Left::Send "^{Home}"     ; Ctrl + Alt + ← = Ctrl + Home（文書の先頭へ）
<!+Left::Send "+{Home}"      ; Alt + Shift + ← = Shift + Home（行頭まで選択）
<^<!+Left::Send "^+{Home}"   ; Ctrl + Alt + Shift + ← = Ctrl + Shift + Home（文書先頭まで選択）

<!Right::Send "{End}"         ; Alt + → = End（行末へ）
<^<!Right::Send "^{End}"     ; Ctrl + Alt + → = Ctrl + End（文書の末尾へ）
<!+Right::Send "+{End}"      ; Alt + Shift + → = Shift + End（行末まで選択）
<^<!+Right::Send "^+{End}"   ; Ctrl + Alt + Shift + → = Ctrl + Shift + End（文書末尾まで選択）

; 単体の左クリック → 通常の左クリックとして動作させつつ “C” を送る、例
; “~” を付けることで元の左クリック動作（マウスクリック）が保持される
; F17:: {
;     ; ただし、Ctrl や Shift 等が押されているときは無視させたい → 条件を付ける
;     if ( GetKeyState("Ctrl", "P") or GetKeyState("Shift", "P") or GetKeyState("Alt", "P") )
;     {
;         ; 他の修飾キー付きクリックとして扱わせたいので、ここでは何もしない
;         ; return しないことで、上の ^LButton／+LButton のブロックが優先されるように
;         return
;     }
;     ; 単体クリック時の処理（たとえば “c” を送る）
;     Send "{LButton}"
;     return
; }

; F17の単体クリックと押しながらの移動処理 ------------
; F17:: {
;     ; 単体クリックの場合は左クリック
;     if !GetKeyState("Up", "P") and !GetKeyState("Down", "P") {
;         Send "{LButton}"
;     }
; }

; ; F17を押しながらの上下移動でスクロール
; #HotIf GetKeyState("F17", "P")
;     Up::Send "{WheelUp}"    ; 上スクロール
;     Down::Send "{WheelDown}" ; 下スクロール
; #HotIf