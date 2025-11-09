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

F19::Send "{Alt down}{``}{Alt up}"
F19 & n::Send "{Volume_Down}"
F19 & m::Send "{Volume_Up}"
F19 & ,::Send "{Media_Play_Pause}"
F19 & p::Send "{Ctrl Down}{Shift Down}{P Down}{P Up}{Shift Up}{Ctrl Up}"

; ####### rikanaa.ahk #######
; --- グローバル変数 ---
g_loggedKeys := ""
g_logMaxLength := 60
g_isDebug := false        ; デバッグモードフラグ
g_logFile := "debug_log.txt"

; --- 入力判定用のキー（英字 + ハイフン） ---
validChars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-"

; --- キーボードフック設定 ---
SetTimer(MonitorKeys, 10)

; --- 左クリック検出 ---
~LButton:: {
    ClearLog()
}

; --- F19 + f 同時押し検出（IMEオン＋再生） ---
~F17:: {
    global g_loggedKeys
    Log("Change active key detected, loggedKeys=" g_loggedKeys)

    if (IME_GET() = 0) {
        Loop StrLen(g_loggedKeys) {
            Send("{Backspace}")
            Sleep(10)  ; ← バックスペース間の遅延（必要に応じて調整）
        }
        ; --- IMEオンにして再入力 ---
        IME_Set(1)
        Sleep(50)
        SendText(g_loggedKeys)
    }else{
        Send "{F10}"
        Sleep(50)
        Send "{Enter}"
        IME_SET(0)
    }

    g_loggedKeys := ""
}

; --- キー監視処理 ---
MonitorKeys() {
    global g_loggedKeys, validChars, g_logMaxLength

    ; --- F17が押されたら無視 ---
    if (GetKeyState("F17", "P")) {
        return
    }

    key := GetKeyPressed()
    if (key != "") {
        Log("Key pressed: " key)
        if InStr(validChars, key) {
            g_loggedKeys .= key
            if (StrLen(g_loggedKeys) > g_logMaxLength) {
                ClearLog()
            }
        } else {
            ClearLog()
        }
        Log("g_loggedKeys: " g_loggedKeys)
    }
}

; --- ログのクリア ---
ClearLog() {
    global g_loggedKeys
    g_loggedKeys := ""
}

; --- キー取得（英字と記号のみ対象） ---
GetKeyPressed() {
    static prevState := Map()
    Loop 254 { ; ← 修正：1〜254の範囲のみチェック
        key := Format("{:02X}", A_Index)
        if (key = "00")
            continue  ; ← vk00をスキップ（念のため安全策）
        state := GetKeyState("vk" key, "P")
        if (state && !prevState.Has(key)) {
            prevState[key] := true
            char := VkToChar(key)
            return char
        } else if (!state && prevState.Has(key)) {
            prevState.Delete(key)
        }
    }
    return ""
}

; --- 仮想キーコードから文字へ変換 ---
VkToChar(vk) {
    try {
        sc := GetKeySC("vk" vk)  ; ← 修正：GetKeyScanCode → GetKeySC
        return GetKeyName(Format("sc{:x}", sc))
    } catch {
        return ""
    }
}

; --- SendText 互換 ---
SendText(text) {
    ; 1文字ずつ送信して変換入力
    for char in StrSplit(text) {
        Send(char)
        Log("SendText: " text)
    }
}

; --- デバッグ用ログ関数 ---
Log(msg) {
    global g_isDebug, g_logFile
    if (!g_isDebug) {
        return
    }
    ; ToolTip(msg)
    FileAppend(A_Now " - " msg "`n", g_logFile, "UTF-8")
}
; ####### rikanaa.ahk #######

; ####### App Active Hide #######
; ; ウィンドウタイトルを完全一致モードに設定
; SetTitleMatchMode 3

; appPath := "C:\Users\noait\AppData\Local\AnthropicClaude\claude.exe"

; ; アプリケーションのウィンドウタイトル（部分一致でOK）
; ; 例: "メモ帳", "Google Chrome", "Visual Studio Code" など
; appTitle := "Claude"

; ; ホットキーの設定（Ctrl + Alt + N）
; ; 変更したい場合は ^!n の部分を変更してください
; ^Space::ToggleApp()

; ; ===== メイン関数 =====
; ToggleApp() {
;     global appPath, appTitle
    
;     ; ウィンドウが存在するか確認
;     if WinExist(appTitle) {
;         ; ウィンドウが最小化されているか確認
;         if WinGetMinMax(appTitle) = -1 {
;             ; 最小化されている場合は復元してアクティブ化
;             WinRestore appTitle
;             WinActivate appTitle
;             ; 常に最前面に表示
;             WinSetAlwaysOnTop true, appTitle
;         } else if WinActive(appTitle) {
;             ; アクティブな場合は最小化する
;             WinMinimize appTitle
;         } else {
;             ; 非アクティブな場合は表示してアクティブ化
;             WinActivate appTitle
;             ; 常に最前面に表示
;             WinSetAlwaysOnTop true, appTitle
;         }
;     } else {
;         ; ウィンドウが存在しない場合は起動
;         try {
;             Run appPath
;             ; 起動後、ウィンドウが表示されるまで待機（3秒）
;             if WinWait(appTitle, , 3) {
;                 ; 常に最前面に表示
;                 WinSetAlwaysOnTop true, appTitle
;             }
;         } catch as err {
;             MsgBox "アプリケーションの起動に失敗しました:`n" err.Message
;         }
;     }
; }
; ####### App Active Hide #######

; 単語登録
; --- 共通ヘルパー ---
SendWithIMERestore(text) {
    prevIME := IME_GET()
    IME_SET(0)               ; 一時的にIMEオフ
    SendText(text)
    Sleep(100)               ; 入力の安定化（必要なら調整）
    IME_SET(prevIME)         ; 元の状態に戻す
}

; --- 曜日付き日付を入力 ---
F19 & 1:: {
    days := ["日", "月", "火", "水", "木", "金", "土"]
    date := A_Now
    year := SubStr(date, 1, 4)
    month := SubStr(date, 5, 2)
    day := SubStr(date, 7, 2)
    dow := FormatTime(date, "WDay") - 1
    weekday := days[dow + 1]
    formatted := Format("{1}年{2}月{3}日({4})", year, month + 0, day + 0, weekday)
    SendWithIMERestore(formatted)
}

; --- 時刻を入力 ---
F19 & 2:: {
    time := FormatTime(A_Now, "HH:mm")
    SendWithIMERestore(time)
}
F19 & 3::SendInput ""
F19 & 4::SendInput ""