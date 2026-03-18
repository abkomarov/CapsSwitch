;
Menu, tray, NoStandard
if !IsUsedInModeEx
  Menu, tray, add, Enable Autorun, MenuHandler1
Menu, tray, add, Disable Autorun, MenuHandler2
Menu, tray, add, Caps on/off, MenuHandler4
Menu, tray, add, Disable/Enable, MenuHandler5
Menu, tray, add, Exit, Exit
Menu, tray, Default, Exit

hkl := DllCall("LoadKeyboardLayout", "Str", "00000409", "UInt", 1, "Ptr")
DllCall("ActivateKeyboardLayout", "Ptr", hkl, "UInt", 0)

#MaxHotkeysPerInterval 10000
; По умолчанию AHK разрешает только 70 срабатываний хоткея в секунду. Если превысить — AHK считает это зависанием и показывает диалог
; "горячая клавиша нажата слишком часто, продолжить?".
; В скрипте каждое нажатие клавиши — это хоткей (~a, ~b и т.д.). При быстрой печати легко превысить 70/сек. Значение 10000 фактически убирает это ограничение.
#MaxThreadsBuffer On    ; for not loosing simultaneous keypresses
; По умолчанию если хоткей срабатывает пока предыдущий ещё обрабатывается — новое нажатие теряется.
; С On — нажатие буферизируется и выполнится сразу после завершения текущего потока.
; При быстрой печати это критично: без буферизации при одновременных нажатиях нескольких клавиш часть просто не попадёт в AllKeys.
SetCapsLockState, AlwaysOff
RegRead, LangToggleKey, HKEY_CURRENT_USER, Keyboard Layout\Toggle, Language Hotkey

KeyBoard= ``1234567890-=qwertyuiop[]\asdfghjkl`;'zxcvbnm,./
Loop Parse, KeyBoard
{
   HotKey  ~%A_LoopField%,   KeyPress
   HotKey ~+%A_LoopField%,   KeyPress
}

NumPad  = Div,Mult,Add,Sub,0,1,2,3,4,5,6,7,8,9,Dot
Loop Parse, NumPad,`,
{
   HotKey  ~NumPad%A_LoopField%,   KeyPress
   HotKey  ~+NumPad%A_LoopField%,   KeyPress
}
KeyPad = Esc,BS,Tab,Enter,Del,Ins,Up,Down,Left,Right,Home,End,PgUp,PgDn,Space
Loop Parse, KeyPad,`,
{
   HotKey  ~%A_LoopField%,   KeyPress
}
; some hotkey will not work:
;Modifers = Shift,Ctrl,Alt
;Loop Parse, Modifers,`,
;{
;   HotKey  ~%A_LoopField%,   KeyPress
;}


KeyPress:               ; All HotKeys activate this subroutine
  StringReplace Key, A_ThisHotKey, ~
  StringReplace Key, Key, NumPad,
  StringReplace Key, Key, %A_Space%up
  StringReplace Key, Key, +
  hasShift := !ErrorLevel
  if hasShift
  {
    ;Key = {Shift Down}%Key%{Shift Up}
    StringUpper, Key, Key
  }

   IfInString, KeyBoard, %Key%
   {
     if DebugEx
       {
       ;FileAppend, %Key% `r`n, log
       ;FileAppend, %A_PriorKey% `r`n, log
       }
   }
   else
   {
     if DebugEx
     {
       ;FileAppend, wrong=%Key% `r`n, log
     }
     AllKeys =
     AllBS =
     return
   }

SetFormat, IntegerFormat, Hex
sc := GetKeySC(Key)        ; sc = "0x1e"
StringTrimLeft, sc, sc, 2  ; sc = "1e"

if hasShift
  AllKeys = %AllKeys%+{sc%sc%}
else
  AllKeys = %AllKeys%{sc%sc%}

SetFormat, IntegerFormat, D
AllBS = %AllBS%{BS}

Return

~LButton::goto KeyPress
~RButton::goto KeyPress
~MButton::goto KeyPress

Exit:
ExitApp
return

MenuHandler1:
shortpath := A_ScriptFullPath
RegWrite, REG_SZ,HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, CapsSwitchHandler, %shortpath%
return

MenuHandler2:
RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, CapsSwitchHandler
return

MenuHandler4:
SendInput {Capslock}
return

MenuHandler5:
Suspend
return

#if !IsUsedInModeEx
Capslock::F15
#if

F15::
;if (A_PriorHotKey = "Capslock up" and A_TimeSincePriorHotkey < 400)
if (A_TickCount - HotkeyTick < 400)
  {
  ;BlockInput On
  ;SendInput {vkC0}_{BS}%AllBS%%AllKeys%
  ;Send {Control}
  ;SendMessage, 0x50, 2, 0,, A ; 0x50 is WM_INPUTLANGCHANGEREQUEST
  ;SendInput {Control Down}{Shift}{Control Up}
  ;Send {Control}
  SendInput _{BS}%AllBS%%AllKeys%
  ;BlockInput Off
  HotkeyTick := 0
  return
  }
  ;KeyWait, CapsLock
  ;Sleep, -1
  ;SendMessage, 0x50, 2, 0,, A ; 0x50 is WM_INPUTLANGCHANGEREQUEST
  ;BlockInput On

if (LangToggleKey = 1)
  SendInput {Shift Down}{Alt}{Shift Up}
else
  SendInput {Control Down}{Shift}{Control Up}

;Send {vkC0}{Control}
;SendInput {vkC0}
;SendMessage, 0x50, 2, 0,, A ; 0x50 is WM_INPUTLANGCHANGEREQUEST
HotkeyTick := A_TickCount

  ;Sleep, 500
  ;BlockInput Off
return


