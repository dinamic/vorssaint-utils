// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Every word the menu bar hiding feature shows: its Settings card and the menu
/// behind the arrow. Kept out of `Strings` because the feature can be switched
/// off entirely, and a separate factory still puts these in front of the
/// localization coverage test for every language.
struct MenuBarHidingStrings {
    let section: String
    let placementHint: String
    let enableToggle: String
    let autoCollapseToggle: String
    let autoCollapseCaption: String
    let autoCollapseSeconds: String
    let hoverToggle: String
    let alwaysHiddenToggle: String
    let alwaysHiddenCaption: String
    let expandTooltip: String
    let collapseTooltip: String
    let expandAccessibilityLabel: String
    let collapseAccessibilityLabel: String
    let alwaysHiddenAccessibilityLabel: String
    let menuExpand: String
    let menuCollapse: String
    let menuEnableAutoCollapse: String
    let menuDisableAutoCollapse: String
    let menuShowSections: String
    let menuHideSections: String
    let menuSettings: String
    let menuTurnOff: String
}

extension FeatureStrings {
    static func menuBarHiding(_ language: AppLanguage) -> MenuBarHidingStrings {
        switch language {
        case .enUS: return .enUS
        case .ptBR: return .ptBR
        case .tr: return .tr
        case .ru: return .ru
        case .es: return .es
        case .sk: return .sk
        case .de: return .de
        case .fr: return .fr
        case .it: return .it
        case .ja: return .ja
        case .ko: return .ko
        case .zhHans: return .zhHans
        case .zhTW: return .zhTW
        case .zhHK: return .zhHK
        case .uk: return .uk
        }
    }
}

extension MenuBarHidingStrings {
    static let enUS = MenuBarHidingStrings(
        section: "Menu bar hiding",
        placementHint: "Hold Command and drag the thin separator between the icons you want to keep and the ones you want to hide.",
        enableToggle: "Collapse menu bar icons",
        autoCollapseToggle: "Collapse again automatically",
        autoCollapseCaption: "Puts the icons back out of sight a moment after you expand them.",
        autoCollapseSeconds: "Wait before collapsing",
        hoverToggle: "Expand on hover",
        alwaysHiddenToggle: "Keep a second section always hidden",
        alwaysHiddenCaption: "Icons past the second separator stay hidden even when the bar is expanded. Option-click the arrow to reveal them.",
        expandTooltip: "Show hidden icons",
        collapseTooltip: "Hide icons",
        expandAccessibilityLabel: "Show hidden menu bar icons",
        collapseAccessibilityLabel: "Hide menu bar icons",
        alwaysHiddenAccessibilityLabel: "Always hidden section separator",
        menuExpand: "Show Hidden Items",
        menuCollapse: "Hide Items",
        menuEnableAutoCollapse: "Turn On Auto Collapse",
        menuDisableAutoCollapse: "Turn Off Auto Collapse",
        menuShowSections: "Show Always Hidden Section",
        menuHideSections: "Hide Always Hidden Section",
        menuSettings: "Settings…",
        menuTurnOff: "Turn Off Menu Bar Hiding"
    )

    static let ptBR = MenuBarHidingStrings(
        section: "Ocultar na barra de menus",
        placementHint: "Mantenha Command pressionado e arraste o separador fino entre os ícones que devem ficar visíveis e os que devem ser ocultados.",
        enableToggle: "Recolher ícones da barra de menus",
        autoCollapseToggle: "Recolher novamente sozinho",
        autoCollapseCaption: "Esconde os ícones de novo pouco depois de você expandi-los.",
        autoCollapseSeconds: "Esperar antes de recolher",
        hoverToggle: "Expandir ao passar o mouse",
        alwaysHiddenToggle: "Manter uma segunda seção sempre oculta",
        alwaysHiddenCaption: "Os ícones após o segundo separador continuam ocultos mesmo com a barra expandida. Use Option e clique na seta para revelá-los.",
        expandTooltip: "Mostrar ícones ocultos",
        collapseTooltip: "Ocultar ícones",
        expandAccessibilityLabel: "Mostrar ícones ocultos da barra de menus",
        collapseAccessibilityLabel: "Ocultar ícones da barra de menus",
        alwaysHiddenAccessibilityLabel: "Separador da seção sempre oculta",
        menuExpand: "Mostrar itens ocultos",
        menuCollapse: "Ocultar itens",
        menuEnableAutoCollapse: "Ativar recolhimento automático",
        menuDisableAutoCollapse: "Desativar recolhimento automático",
        menuShowSections: "Mostrar seção sempre oculta",
        menuHideSections: "Ocultar seção sempre oculta",
        menuSettings: "Ajustes…",
        menuTurnOff: "Desativar ocultação da barra de menus"
    )

    static let tr = MenuBarHidingStrings(
        section: "Menü çubuğunu gizleme",
        placementHint: "Command tuşunu basılı tutup ince ayırıcıyı görünür kalmasını istediğiniz simgelerle gizlenecek simgeler arasına sürükleyin.",
        enableToggle: "Menü çubuğu simgelerini daralt",
        autoCollapseToggle: "Kendiliğinden yeniden daralt",
        autoCollapseCaption: "Genişlettiğiniz simgeleri bir süre sonra yeniden gizler.",
        autoCollapseSeconds: "Daraltmadan önce bekle",
        hoverToggle: "Üzerine gelince genişlet",
        alwaysHiddenToggle: "İkinci bölümü her zaman gizli tut",
        alwaysHiddenCaption: "İkinci ayırıcının ötesindeki simgeler çubuk genişletilmiş olsa da gizli kalır. Göstermek için ok simgesine Option ile tıklayın.",
        expandTooltip: "Gizli simgeleri göster",
        collapseTooltip: "Simgeleri gizle",
        expandAccessibilityLabel: "Gizli menü çubuğu simgelerini göster",
        collapseAccessibilityLabel: "Menü çubuğu simgelerini gizle",
        alwaysHiddenAccessibilityLabel: "Her zaman gizli bölümün ayırıcısı",
        menuExpand: "Gizli ögeleri göster",
        menuCollapse: "Ögeleri gizle",
        menuEnableAutoCollapse: "Otomatik daraltmayı aç",
        menuDisableAutoCollapse: "Otomatik daraltmayı kapat",
        menuShowSections: "Her zaman gizli bölümü göster",
        menuHideSections: "Her zaman gizli bölümü gizle",
        menuSettings: "Ayarlar…",
        menuTurnOff: "Menü çubuğu gizlemeyi kapat"
    )

    static let ru = MenuBarHidingStrings(
        section: "Скрытие значков в строке меню",
        placementHint: "Удерживая Command, перетащите тонкий разделитель между значками, которые должны остаться, и теми, которые нужно скрыть.",
        enableToggle: "Сворачивать значки строки меню",
        autoCollapseToggle: "Сворачивать снова автоматически",
        autoCollapseCaption: "Снова скрывает значки через некоторое время после разворачивания.",
        autoCollapseSeconds: "Ждать перед сворачиванием",
        hoverToggle: "Разворачивать при наведении",
        alwaysHiddenToggle: "Держать второй раздел всегда скрытым",
        alwaysHiddenCaption: "Значки за вторым разделителем остаются скрытыми даже при развёрнутой строке. Чтобы показать их, нажмите на стрелку с Option.",
        expandTooltip: "Показать скрытые значки",
        collapseTooltip: "Скрыть значки",
        expandAccessibilityLabel: "Показать скрытые значки строки меню",
        collapseAccessibilityLabel: "Скрыть значки строки меню",
        alwaysHiddenAccessibilityLabel: "Разделитель всегда скрытого раздела",
        menuExpand: "Показать скрытые объекты",
        menuCollapse: "Скрыть объекты",
        menuEnableAutoCollapse: "Включить автосворачивание",
        menuDisableAutoCollapse: "Отключить автосворачивание",
        menuShowSections: "Показать всегда скрытый раздел",
        menuHideSections: "Скрыть всегда скрытый раздел",
        menuSettings: "Настройки…",
        menuTurnOff: "Отключить скрытие строки меню"
    )

    static let es = MenuBarHidingStrings(
        section: "Ocultación en la barra de menús",
        placementHint: "Mantén pulsada la tecla Command y arrastra el separador fino entre los iconos que quieres conservar y los que quieres ocultar.",
        enableToggle: "Contraer los iconos de la barra de menús",
        autoCollapseToggle: "Contraer de nuevo automáticamente",
        autoCollapseCaption: "Vuelve a ocultar los iconos un momento después de expandirlos.",
        autoCollapseSeconds: "Esperar antes de contraer",
        hoverToggle: "Expandir al pasar el puntero",
        alwaysHiddenToggle: "Mantener una segunda sección siempre oculta",
        alwaysHiddenCaption: "Los iconos tras el segundo separador siguen ocultos aunque la barra esté expandida. Pulsa la flecha con Option para mostrarlos.",
        expandTooltip: "Mostrar iconos ocultos",
        collapseTooltip: "Ocultar iconos",
        expandAccessibilityLabel: "Mostrar los iconos ocultos de la barra de menús",
        collapseAccessibilityLabel: "Ocultar los iconos de la barra de menús",
        alwaysHiddenAccessibilityLabel: "Separador de la sección siempre oculta",
        menuExpand: "Mostrar elementos ocultos",
        menuCollapse: "Ocultar elementos",
        menuEnableAutoCollapse: "Activar la contracción automática",
        menuDisableAutoCollapse: "Desactivar la contracción automática",
        menuShowSections: "Mostrar la sección siempre oculta",
        menuHideSections: "Ocultar la sección siempre oculta",
        menuSettings: "Ajustes…",
        menuTurnOff: "Desactivar la ocultación en la barra de menús"
    )

    static let sk = MenuBarHidingStrings(
        section: "Skrývanie v paneli ponúk",
        placementHint: "Podržte Command a presuňte tenký oddeľovač medzi ikony, ktoré majú zostať viditeľné, a tie, ktoré sa majú skryť.",
        enableToggle: "Zbaliť ikony panela ponúk",
        autoCollapseToggle: "Znova zbaliť automaticky",
        autoCollapseCaption: "Po chvíli od rozbalenia ikony opäť skryje.",
        autoCollapseSeconds: "Čakať pred zbalením",
        hoverToggle: "Rozbaliť pri prejdení kurzorom",
        alwaysHiddenToggle: "Ponechať druhú časť vždy skrytú",
        alwaysHiddenCaption: "Ikony za druhým oddeľovačom zostanú skryté aj pri rozbalenom paneli. Zobrazíte ich kliknutím na šípku s klávesom Option.",
        expandTooltip: "Zobraziť skryté ikony",
        collapseTooltip: "Skryť ikony",
        expandAccessibilityLabel: "Zobraziť skryté ikony panela ponúk",
        collapseAccessibilityLabel: "Skryť ikony panela ponúk",
        alwaysHiddenAccessibilityLabel: "Oddeľovač vždy skrytej časti",
        menuExpand: "Zobraziť skryté položky",
        menuCollapse: "Skryť položky",
        menuEnableAutoCollapse: "Zapnúť automatické zbalenie",
        menuDisableAutoCollapse: "Vypnúť automatické zbalenie",
        menuShowSections: "Zobraziť vždy skrytú časť",
        menuHideSections: "Skryť vždy skrytú časť",
        menuSettings: "Nastavenia…",
        menuTurnOff: "Vypnúť skrývanie v paneli ponúk"
    )

    static let de = MenuBarHidingStrings(
        section: "Menüleiste ausblenden",
        placementHint: "Halte die Befehlstaste gedrückt und ziehe den schmalen Trenner zwischen die Symbole, die sichtbar bleiben sollen, und die, die verschwinden sollen.",
        enableToggle: "Symbole der Menüleiste einklappen",
        autoCollapseToggle: "Automatisch wieder einklappen",
        autoCollapseCaption: "Blendet die Symbole kurz nach dem Ausklappen wieder aus.",
        autoCollapseSeconds: "Wartezeit vor dem Einklappen",
        hoverToggle: "Beim Darüberfahren ausklappen",
        alwaysHiddenToggle: "Einen zweiten Bereich immer ausgeblendet halten",
        alwaysHiddenCaption: "Symbole hinter dem zweiten Trenner bleiben auch bei ausgeklappter Leiste ausgeblendet. Mit Option-Klick auf den Pfeil werden sie sichtbar.",
        expandTooltip: "Ausgeblendete Symbole einblenden",
        collapseTooltip: "Symbole ausblenden",
        expandAccessibilityLabel: "Ausgeblendete Symbole der Menüleiste einblenden",
        collapseAccessibilityLabel: "Symbole der Menüleiste ausblenden",
        alwaysHiddenAccessibilityLabel: "Trenner des immer ausgeblendeten Bereichs",
        menuExpand: "Ausgeblendete Objekte einblenden",
        menuCollapse: "Objekte ausblenden",
        menuEnableAutoCollapse: "Automatisches Einklappen einschalten",
        menuDisableAutoCollapse: "Automatisches Einklappen ausschalten",
        menuShowSections: "Immer ausgeblendeten Bereich einblenden",
        menuHideSections: "Immer ausgeblendeten Bereich ausblenden",
        menuSettings: "Einstellungen…",
        menuTurnOff: "Ausblenden der Menüleiste ausschalten"
    )

    static let fr = MenuBarHidingStrings(
        section: "Masquage dans la barre des menus",
        placementHint: "Maintenez la touche Commande et faites glisser le fin séparateur entre les icônes à conserver et celles à masquer.",
        enableToggle: "Replier les icônes de la barre des menus",
        autoCollapseToggle: "Replier automatiquement à nouveau",
        autoCollapseCaption: "Masque de nouveau les icônes peu après les avoir déployées.",
        autoCollapseSeconds: "Attendre avant de replier",
        hoverToggle: "Déployer au survol",
        alwaysHiddenToggle: "Garder une seconde section toujours masquée",
        alwaysHiddenCaption: "Les icônes au-delà du second séparateur restent masquées même lorsque la barre est déployée. Option-cliquez sur la flèche pour les révéler.",
        expandTooltip: "Afficher les icônes masquées",
        collapseTooltip: "Masquer les icônes",
        expandAccessibilityLabel: "Afficher les icônes masquées de la barre des menus",
        collapseAccessibilityLabel: "Masquer les icônes de la barre des menus",
        alwaysHiddenAccessibilityLabel: "Séparateur de la section toujours masquée",
        menuExpand: "Afficher les éléments masqués",
        menuCollapse: "Masquer les éléments",
        menuEnableAutoCollapse: "Activer le repli automatique",
        menuDisableAutoCollapse: "Désactiver le repli automatique",
        menuShowSections: "Afficher la section toujours masquée",
        menuHideSections: "Masquer la section toujours masquée",
        menuSettings: "Réglages…",
        menuTurnOff: "Désactiver le masquage dans la barre des menus"
    )

    static let it = MenuBarHidingStrings(
        section: "Nascondi nella barra dei menu",
        placementHint: "Tieni premuto Command e trascina il separatore sottile tra le icone da mantenere visibili e quelle da nascondere.",
        enableToggle: "Comprimi le icone della barra dei menu",
        autoCollapseToggle: "Comprimi di nuovo automaticamente",
        autoCollapseCaption: "Nasconde di nuovo le icone poco dopo averle espanse.",
        autoCollapseSeconds: "Attesa prima di comprimere",
        hoverToggle: "Espandi al passaggio del puntatore",
        alwaysHiddenToggle: "Mantieni una seconda sezione sempre nascosta",
        alwaysHiddenCaption: "Le icone oltre il secondo separatore restano nascoste anche con la barra espansa. Fai Option-clic sulla freccia per mostrarle.",
        expandTooltip: "Mostra le icone nascoste",
        collapseTooltip: "Nascondi le icone",
        expandAccessibilityLabel: "Mostra le icone nascoste della barra dei menu",
        collapseAccessibilityLabel: "Nascondi le icone della barra dei menu",
        alwaysHiddenAccessibilityLabel: "Separatore della sezione sempre nascosta",
        menuExpand: "Mostra gli elementi nascosti",
        menuCollapse: "Nascondi gli elementi",
        menuEnableAutoCollapse: "Attiva la compressione automatica",
        menuDisableAutoCollapse: "Disattiva la compressione automatica",
        menuShowSections: "Mostra la sezione sempre nascosta",
        menuHideSections: "Nascondi la sezione sempre nascosta",
        menuSettings: "Impostazioni…",
        menuTurnOff: "Disattiva la scomparsa nella barra dei menu"
    )

    static let ja = MenuBarHidingStrings(
        section: "メニューバーの非表示",
        placementHint: "Command キーを押したまま細い区切りをドラッグし、表示したままにするアイコンと隠すアイコンの間に置きます。",
        enableToggle: "メニューバーのアイコンを折りたたむ",
        autoCollapseToggle: "自動で再び折りたたむ",
        autoCollapseCaption: "展開したアイコンをしばらくして再び隠します。",
        autoCollapseSeconds: "折りたたむまでの待ち時間",
        hoverToggle: "ポインタを合わせて展開",
        alwaysHiddenToggle: "2 つ目の区画を常に隠す",
        alwaysHiddenCaption: "2 つ目の区切りの先にあるアイコンは、バーを展開しても隠れたままです。表示するには Option キーを押しながら矢印をクリックします。",
        expandTooltip: "隠れているアイコンを表示",
        collapseTooltip: "アイコンを隠す",
        expandAccessibilityLabel: "メニューバーの隠れているアイコンを表示",
        collapseAccessibilityLabel: "メニューバーのアイコンを隠す",
        alwaysHiddenAccessibilityLabel: "常に隠す区画の区切り",
        menuExpand: "隠れている項目を表示",
        menuCollapse: "項目を隠す",
        menuEnableAutoCollapse: "自動折りたたみをオンにする",
        menuDisableAutoCollapse: "自動折りたたみをオフにする",
        menuShowSections: "常に隠す区画を表示",
        menuHideSections: "常に隠す区画を隠す",
        menuSettings: "設定…",
        menuTurnOff: "メニューバーの非表示をオフにする"
    )

    static let ko = MenuBarHidingStrings(
        section: "메뉴 막대 숨기기",
        placementHint: "Command 키를 누른 채 얇은 구분선을 남길 아이콘과 숨길 아이콘 사이로 드래그하십시오.",
        enableToggle: "메뉴 막대 아이콘 접기",
        autoCollapseToggle: "자동으로 다시 접기",
        autoCollapseCaption: "펼친 아이콘을 잠시 후 다시 숨깁니다.",
        autoCollapseSeconds: "접기까지 기다리는 시간",
        hoverToggle: "포인터를 올리면 펼치기",
        alwaysHiddenToggle: "두 번째 구역을 항상 숨겨 두기",
        alwaysHiddenCaption: "두 번째 구분선 너머의 아이콘은 막대를 펼쳐도 계속 숨겨집니다. 표시하려면 화살표를 Option 키와 함께 클릭하십시오.",
        expandTooltip: "숨긴 아이콘 보기",
        collapseTooltip: "아이콘 숨기기",
        expandAccessibilityLabel: "숨긴 메뉴 막대 아이콘 보기",
        collapseAccessibilityLabel: "메뉴 막대 아이콘 숨기기",
        alwaysHiddenAccessibilityLabel: "항상 숨기는 구역의 구분선",
        menuExpand: "숨긴 항목 보기",
        menuCollapse: "항목 숨기기",
        menuEnableAutoCollapse: "자동 접기 켜기",
        menuDisableAutoCollapse: "자동 접기 끄기",
        menuShowSections: "항상 숨기는 구역 보기",
        menuHideSections: "항상 숨기는 구역 숨기기",
        menuSettings: "설정…",
        menuTurnOff: "메뉴 막대 숨기기 끄기"
    )

    static let zhHans = MenuBarHidingStrings(
        section: "菜单栏隐藏",
        placementHint: "按住 Command 键拖动细分隔线，把它放在要保留和要隐藏的图标之间。",
        enableToggle: "折叠菜单栏图标",
        autoCollapseToggle: "自动再次折叠",
        autoCollapseCaption: "展开图标片刻后重新隐藏它们。",
        autoCollapseSeconds: "折叠前等待",
        hoverToggle: "悬停时展开",
        alwaysHiddenToggle: "始终隐藏第二个区域",
        alwaysHiddenCaption: "第二条分隔线之后的图标即使在菜单栏展开时也会隐藏。按住 Option 点击箭头即可显示它们。",
        expandTooltip: "显示隐藏的图标",
        collapseTooltip: "隐藏图标",
        expandAccessibilityLabel: "显示隐藏的菜单栏图标",
        collapseAccessibilityLabel: "隐藏菜单栏图标",
        alwaysHiddenAccessibilityLabel: "始终隐藏区域的分隔线",
        menuExpand: "显示隐藏的项目",
        menuCollapse: "隐藏项目",
        menuEnableAutoCollapse: "开启自动折叠",
        menuDisableAutoCollapse: "关闭自动折叠",
        menuShowSections: "显示始终隐藏的区域",
        menuHideSections: "隐藏始终隐藏的区域",
        menuSettings: "设置…",
        menuTurnOff: "关闭菜单栏隐藏"
    )

    static let zhTW = MenuBarHidingStrings(
        section: "選單列隱藏",
        placementHint: "按住 Command 鍵拖曳細分隔線，將它放在要保留和要隱藏的圖示之間。",
        enableToggle: "摺疊選單列圖示",
        autoCollapseToggle: "自動再次摺疊",
        autoCollapseCaption: "展開圖示片刻後重新隱藏它們。",
        autoCollapseSeconds: "摺疊前等待",
        hoverToggle: "游標停留時展開",
        alwaysHiddenToggle: "永遠隱藏第二個區域",
        alwaysHiddenCaption: "第二條分隔線之後的圖示即使在選單列展開時也會隱藏。按住 Option 鍵點按箭頭即可顯示它們。",
        expandTooltip: "顯示隱藏的圖示",
        collapseTooltip: "隱藏圖示",
        expandAccessibilityLabel: "顯示隱藏的選單列圖示",
        collapseAccessibilityLabel: "隱藏選單列圖示",
        alwaysHiddenAccessibilityLabel: "永遠隱藏區域的分隔線",
        menuExpand: "顯示隱藏的項目",
        menuCollapse: "隱藏項目",
        menuEnableAutoCollapse: "開啟自動摺疊",
        menuDisableAutoCollapse: "關閉自動摺疊",
        menuShowSections: "顯示永遠隱藏的區域",
        menuHideSections: "隱藏永遠隱藏的區域",
        menuSettings: "設定…",
        menuTurnOff: "關閉選單列隱藏"
    )

    static let zhHK = MenuBarHidingStrings(
        section: "選單列隱藏",
        placementHint: "按住 Command 鍵拖曳幼分隔線，將它放在要保留和要隱藏的圖示之間。",
        enableToggle: "摺疊選單列圖示",
        autoCollapseToggle: "自動再次摺疊",
        autoCollapseCaption: "展開圖示片刻後重新隱藏它們。",
        autoCollapseSeconds: "摺疊前等待",
        hoverToggle: "游標停留時展開",
        alwaysHiddenToggle: "永遠隱藏第二個區域",
        alwaysHiddenCaption: "第二條分隔線之後的圖示即使在選單列展開時也會隱藏。按住 Option 鍵點按箭嘴即可顯示它們。",
        expandTooltip: "顯示隱藏的圖示",
        collapseTooltip: "隱藏圖示",
        expandAccessibilityLabel: "顯示隱藏的選單列圖示",
        collapseAccessibilityLabel: "隱藏選單列圖示",
        alwaysHiddenAccessibilityLabel: "永遠隱藏區域的分隔線",
        menuExpand: "顯示隱藏的項目",
        menuCollapse: "隱藏項目",
        menuEnableAutoCollapse: "開啟自動摺疊",
        menuDisableAutoCollapse: "關閉自動摺疊",
        menuShowSections: "顯示永遠隱藏的區域",
        menuHideSections: "隱藏永遠隱藏的區域",
        menuSettings: "設定…",
        menuTurnOff: "關閉選單列隱藏"
    )

    static let uk = MenuBarHidingStrings(
        section: "Приховування в рядку меню",
        placementHint: "Утримуйте Command і перетягніть тонкий розділювач між значками, які мають залишитися, і тими, які потрібно приховати.",
        enableToggle: "Згортати значки рядка меню",
        autoCollapseToggle: "Згортати знову автоматично",
        autoCollapseCaption: "Знову ховає значки через деякий час після розгортання.",
        autoCollapseSeconds: "Чекати перед згортанням",
        hoverToggle: "Розгортати при наведенні",
        alwaysHiddenToggle: "Тримати другий розділ завжди прихованим",
        alwaysHiddenCaption: "Значки за другим розділювачем залишаються прихованими навіть у розгорнутому рядку. Щоб показати їх, натисніть на стрілку з Option.",
        expandTooltip: "Показати приховані значки",
        collapseTooltip: "Приховати значки",
        expandAccessibilityLabel: "Показати приховані значки рядка меню",
        collapseAccessibilityLabel: "Приховати значки рядка меню",
        alwaysHiddenAccessibilityLabel: "Розділювач завжди прихованого розділу",
        menuExpand: "Показати приховані об'єкти",
        menuCollapse: "Приховати об'єкти",
        menuEnableAutoCollapse: "Увімкнути автозгортання",
        menuDisableAutoCollapse: "Вимкнути автозгортання",
        menuShowSections: "Показати завжди прихований розділ",
        menuHideSections: "Приховати завжди прихований розділ",
        menuSettings: "Налаштування…",
        menuTurnOff: "Вимкнути приховування в рядку меню"
    )
}
