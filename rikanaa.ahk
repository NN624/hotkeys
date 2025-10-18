; AutoHotkey v2.0 スクリプト - 「りかなー」仕様の実装（キー: F19 + f）

#Requires AutoHotkey v2.0

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

    Loop StrLen(g_loggedKeys) {
        Send("{Backspace}")
        Sleep(10)  ; ← バックスペース間の遅延（必要に応じて調整）
    }
    ; --- IMEオンにして再入力 ---
    IME_Set(1)
    Sleep(50)
    SendText(g_loggedKeys)
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

; --- IME操作（オン=1, オフ=0）---
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
