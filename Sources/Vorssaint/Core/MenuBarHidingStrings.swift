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
    let startCollapsedToggle: String
    let startCollapsedCaption: String
    let separatorAccessibilityLabel: String
    let unavailableTitle: String
    let unavailableCaption: String
    /// macOS 27 conceals whole apps rather than a positional section, so the
    /// card explains the different model instead of showing placement advice.
    let assessmentCaption: String
    /// macOS blocks clicks on its own menu bar items while an assertion is
    /// live, so the clock stays visible but cannot open Notification Centre.
    let assessmentClockCaption: String
    let appPickerTitle: String
    let appPickerCaption: String
    let applicationsFolderCaption: String
    let assessmentUnavailableCaption: String
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
        menuTurnOff: "Turn Off Menu Bar Hiding",
        startCollapsedToggle: "Collapse as soon as it turns on",
        startCollapsedCaption: "Hides the icons right away instead of waiting for you to click the arrow.",
        separatorAccessibilityLabel: "Menu bar section separator. Hold Command and drag to place it.",
        unavailableTitle: "Menu bar hiding is unavailable",
        unavailableCaption: "This version of macOS does not let Vorssaint resize menu bar items, so the icons cannot be collapsed. Your menu bar was left unchanged.",
        assessmentCaption: "On this version of macOS, hiding works per app: choose the apps whose menu bar icons should be concealed. There is no separator to drag.",
        assessmentClockCaption: "While icons are hidden, macOS blocks clicks on the clock, so Notification Centre does not open until you show the icons again.",
        appPickerTitle: "Apps to hide",
        appPickerCaption: "Every other running app stays visible. New apps are added to the allowlist automatically.",
        applicationsFolderCaption: "Vorssaint must run from /Applications for this to work. A copy run from Downloads or a build folder will hide its own icon.",
        assessmentUnavailableCaption: "This version of macOS does not have the menu bar concealment facility Vorssaint uses. Your menu bar was left unchanged."
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
        menuTurnOff: "Desativar ocultação da barra de menus",
        startCollapsedToggle: "Recolher assim que for ativado",
        startCollapsedCaption: "Oculta os ícones imediatamente, sem esperar que você clique na seta.",
        separatorAccessibilityLabel: "Separador da seção da barra de menus. Mantenha Command pressionado e arraste para posicioná-lo.",
        unavailableTitle: "Ocultação na barra de menus indisponível",
        unavailableCaption: "Esta versão do macOS não permite que o Vorssaint redimensione itens da barra de menus, então os ícones não podem ser recolhidos. Sua barra de menus não foi alterada.",
        assessmentCaption: "Nesta versão do macOS, a ocultação funciona por app: escolha os apps cujos ícones da barra de menus devem ser ocultados. Não há separador para arrastar.",
        assessmentClockCaption: "Enquanto os ícones estiverem ocultos, o macOS bloqueia cliques no relógio, então a Central de Notificações não abre até você mostrar os ícones novamente.",
        appPickerTitle: "Apps para ocultar",
        appPickerCaption: "Todos os outros apps em execução continuam visíveis. Apps novos entram na lista permitida automaticamente.",
        applicationsFolderCaption: "O Vorssaint precisa ser executado a partir de /Applications para isso funcionar. Uma cópia executada de Downloads ou de uma pasta de compilação ocultará o próprio ícone.",
        assessmentUnavailableCaption: "Esta versão do macOS não tem o recurso de ocultação da barra de menus que o Vorssaint usa. Sua barra de menus não foi alterada."
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
        menuTurnOff: "Menü çubuğu gizlemeyi kapat",
        startCollapsedToggle: "Açılır açılmaz daralt",
        startCollapsedCaption: "Ok simgesine tıklamanızı beklemeden simgeleri hemen gizler.",
        separatorAccessibilityLabel: "Menü çubuğu bölüm ayırıcısı. Yerleştirmek için Command tuşunu basılı tutup sürükleyin.",
        unavailableTitle: "Menü çubuğunu gizleme kullanılamıyor",
        unavailableCaption: "Bu macOS sürümü Vorssaint’in menü çubuğu ögelerini yeniden boyutlandırmasına izin vermediği için simgeler daraltılamıyor. Menü çubuğunuz değiştirilmedi.",
        assessmentCaption: "Bu macOS sürümünde gizleme uygulama bazındadır: menü çubuğu simgeleri gizlenecek uygulamaları seçin. Sürüklenecek bir ayırıcı yoktur.",
        assessmentClockCaption: "Simgeler gizliyken macOS saat tıklamalarını engeller; Bildirim Merkezi simgeleri yeniden gösterene kadar açılmaz.",
        appPickerTitle: "Gizlenecek uygulamalar",
        appPickerCaption: "Çalışan diğer tüm uygulamalar görünür kalır. Yeni uygulamalar izin listesine otomatik olarak eklenir.",
        applicationsFolderCaption: "Bunun çalışması için Vorssaint /Applications klasöründen çalışmalıdır. İndirilenler veya bir derleme klasöründen çalıştırılan kopya kendi simgesini gizler.",
        assessmentUnavailableCaption: "Bu macOS sürümünde Vorssaint’in kullandığı menü çubuğu gizleme özelliği yok. Menü çubuğunuz değiştirilmedi."
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
        menuTurnOff: "Отключить скрытие строки меню",
        startCollapsedToggle: "Сворачивать сразу после включения",
        startCollapsedCaption: "Скрывает значки сразу, не дожидаясь нажатия на стрелку.",
        separatorAccessibilityLabel: "Разделитель раздела строки меню. Удерживайте Command и перетащите, чтобы разместить его.",
        unavailableTitle: "Скрытие строки меню недоступно",
        unavailableCaption: "Эта версия macOS не позволяет Vorssaint изменять размер элементов строки меню, поэтому значки нельзя свернуть. Строка меню осталась без изменений.",
        assessmentCaption: "В этой версии macOS скрытие работает по приложениям: выберите приложения, значки которых нужно скрыть. Разделителя для перетаскивания нет.",
        assessmentClockCaption: "Пока значки скрыты, macOS блокирует нажатия на часы, поэтому Центр уведомлений не откроется, пока вы снова не покажете значки.",
        appPickerTitle: "Приложения для скрытия",
        appPickerCaption: "Все остальные запущенные приложения остаются видимыми. Новые приложения автоматически добавляются в список разрешённых.",
        applicationsFolderCaption: "Чтобы это работало, Vorssaint должен запускаться из /Applications. Копия, запущенная из Загрузок или папки сборки, скроет собственный значок.",
        assessmentUnavailableCaption: "В этой версии macOS нет средства скрытия строки меню, которое использует Vorssaint. Строка меню осталась без изменений."
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
        menuTurnOff: "Desactivar la ocultación en la barra de menús",
        startCollapsedToggle: "Contraer en cuanto se activa",
        startCollapsedCaption: "Oculta los iconos de inmediato en lugar de esperar a que pulses la flecha.",
        separatorAccessibilityLabel: "Separador de la sección de la barra de menús. Mantén Command y arrástralo para colocarlo.",
        unavailableTitle: "La ocultación en la barra de menús no está disponible",
        unavailableCaption: "Esta versión de macOS no permite que Vorssaint cambie el tamaño de los elementos de la barra de menús, así que los iconos no se pueden contraer. La barra de menús no se ha modificado.",
        assessmentCaption: "En esta versión de macOS, la ocultación funciona por app: elige las apps cuyos iconos de la barra de menús quieres ocultar. No hay ningún separador que arrastrar.",
        assessmentClockCaption: "Mientras los iconos estén ocultos, macOS bloquea los clics en el reloj, así que el Centro de notificaciones no se abre hasta que vuelvas a mostrar los iconos.",
        appPickerTitle: "Apps que ocultar",
        appPickerCaption: "Todas las demás apps en ejecución siguen visibles. Las apps nuevas se añaden a la lista permitida automáticamente.",
        applicationsFolderCaption: "Vorssaint debe ejecutarse desde /Applications para que esto funcione. Una copia ejecutada desde Descargas o desde una carpeta de compilación ocultará su propio icono.",
        assessmentUnavailableCaption: "Esta versión de macOS no tiene el recurso de ocultación de la barra de menús que usa Vorssaint. La barra de menús no se ha modificado."
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
        menuTurnOff: "Vypnúť skrývanie v paneli ponúk",
        startCollapsedToggle: "Zbaliť hneď po zapnutí",
        startCollapsedCaption: "Skryje ikony okamžite namiesto čakania na kliknutie na šípku.",
        separatorAccessibilityLabel: "Oddeľovač časti panela ponúk. Podržte Command a presuňte ho na miesto.",
        unavailableTitle: "Skrývanie v paneli ponúk nie je dostupné",
        unavailableCaption: "Táto verzia macOS neumožňuje aplikácii Vorssaint meniť veľkosť položiek panela ponúk, preto sa ikony nedajú zbaliť. Panel ponúk zostal nezmenený.",
        assessmentCaption: "V tejto verzii macOS funguje skrývanie podľa aplikácií: vyberte aplikácie, ktorých ikony panela ponúk sa majú skryť. Nie je tu žiadny oddeľovač na presunutie.",
        assessmentClockCaption: "Kým sú ikony skryté, macOS blokuje kliknutia na hodiny, takže Centrum oznámení sa neotvorí, kým ikony znova nezobrazíte.",
        appPickerTitle: "Aplikácie na skrytie",
        appPickerCaption: "Všetky ostatné spustené aplikácie zostávajú viditeľné. Nové aplikácie sa automaticky pridajú do zoznamu povolených.",
        applicationsFolderCaption: "Aby to fungovalo, Vorssaint musí bežať z /Applications. Kópia spustená zo Stiahnutých súborov alebo z priečinka zostavenia skryje vlastnú ikonu.",
        assessmentUnavailableCaption: "Táto verzia macOS nemá funkciu skrývania panela ponúk, ktorú Vorssaint používa. Panel ponúk zostal nezmenený."
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
        menuTurnOff: "Ausblenden der Menüleiste ausschalten",
        startCollapsedToggle: "Beim Einschalten sofort einklappen",
        startCollapsedCaption: "Blendet die Symbole sofort aus, statt auf einen Klick auf den Pfeil zu warten.",
        separatorAccessibilityLabel: "Trenner des Menüleistenbereichs. Halte die Befehlstaste gedrückt und ziehe ihn an seinen Platz.",
        unavailableTitle: "Ausblenden der Menüleiste ist nicht verfügbar",
        unavailableCaption: "Diese macOS-Version erlaubt Vorssaint nicht, Elemente der Menüleiste zu vergrößern, daher lassen sich die Symbole nicht einklappen. Deine Menüleiste blieb unverändert.",
        assessmentCaption: "Unter dieser macOS-Version wird pro App ausgeblendet: Wähle die Apps, deren Menüleisten-Symbole verschwinden sollen. Es gibt keinen Separator zum Ziehen.",
        assessmentClockCaption: "Solange Symbole ausgeblendet sind, blockiert macOS Klicks auf die Uhr. Das Benachrichtigungszentrum öffnet sich erst, wenn du die Symbole wieder einblendest.",
        appPickerTitle: "Apps zum Ausblenden",
        appPickerCaption: "Alle anderen laufenden Apps bleiben sichtbar. Neue Apps werden automatisch zur erlaubten Liste hinzugefügt.",
        applicationsFolderCaption: "Damit das funktioniert, muss Vorssaint aus /Applications laufen. Eine Kopie aus „Downloads“ oder einem Build-Ordner blendet das eigene Symbol aus.",
        assessmentUnavailableCaption: "Diese macOS-Version hat nicht die Funktion zum Ausblenden der Menüleiste, die Vorssaint verwendet. Deine Menüleiste blieb unverändert."
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
        menuTurnOff: "Désactiver le masquage dans la barre des menus",
        startCollapsedToggle: "Replier dès l’activation",
        startCollapsedCaption: "Masque les icônes immédiatement au lieu d’attendre un clic sur la flèche.",
        separatorAccessibilityLabel: "Séparateur de section de la barre des menus. Maintenez Commande et faites-le glisser pour le placer.",
        unavailableTitle: "Le masquage dans la barre des menus est indisponible",
        unavailableCaption: "Cette version de macOS ne permet pas à Vorssaint de redimensionner les éléments de la barre des menus, donc les icônes ne peuvent pas être repliées. Votre barre des menus n’a pas été modifiée.",
        assessmentCaption: "Avec cette version de macOS, le masquage se fait par app. Choisissez les apps dont les icônes de la barre des menus doivent être masquées. Il n’y a aucun séparateur à faire glisser.",
        assessmentClockCaption: "Tant que les icônes sont masquées, macOS bloque les clics sur l’horloge. Le Centre de notifications ne s’ouvre qu’après avoir réaffiché les icônes.",
        appPickerTitle: "Apps à masquer",
        appPickerCaption: "Toutes les autres apps en cours d’exécution restent visibles. Les nouvelles apps sont ajoutées automatiquement à la liste autorisée.",
        applicationsFolderCaption: "Vorssaint doit être exécuté depuis /Applications pour que cela fonctionne. Une copie lancée depuis Téléchargements ou un dossier de compilation masquera sa propre icône.",
        assessmentUnavailableCaption: "Cette version de macOS ne dispose pas de la fonction de masquage de la barre des menus utilisée par Vorssaint. Votre barre des menus n’a pas été modifiée."
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
        menuTurnOff: "Disattiva la scomparsa nella barra dei menu",
        startCollapsedToggle: "Comprimi all’attivazione",
        startCollapsedCaption: "Nasconde subito le icone senza attendere un clic sulla freccia.",
        separatorAccessibilityLabel: "Separatore della sezione della barra dei menu. Tieni premuto Command e trascinalo per posizionarlo.",
        unavailableTitle: "La scomparsa nella barra dei menu non è disponibile",
        unavailableCaption: "Questa versione di macOS non consente a Vorssaint di ridimensionare gli elementi della barra dei menu, quindi le icone non possono essere compresse. La barra dei menu è rimasta invariata.",
        assessmentCaption: "In questa versione di macOS la dissimulazione funziona per app: scegli le app le cui icone della barra dei menu devono essere nascoste. Non c’è alcun separatore da trascinare.",
        assessmentClockCaption: "Finché le icone sono nascoste, macOS blocca i clic sull’orologio, quindi il Centro notifiche non si apre finché non le mostri di nuovo.",
        appPickerTitle: "App da nascondere",
        appPickerCaption: "Tutte le altre app in esecuzione restano visibili. Le nuove app vengono aggiunte automaticamente all’elenco consentito.",
        applicationsFolderCaption: "Perché funzioni, Vorssaint deve essere eseguito da /Applications. Una copia avviata da Download o da una cartella di compilazione nasconderà la propria icona.",
        assessmentUnavailableCaption: "Questa versione di macOS non dispone della funzione di occultamento della barra dei menu usata da Vorssaint. La barra dei menu è rimasta invariata."
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
        menuTurnOff: "メニューバーの非表示をオフにする",
        startCollapsedToggle: "オンにしたらすぐ折りたたむ",
        startCollapsedCaption: "矢印をクリックするのを待たずに、すぐにアイコンを隠します。",
        separatorAccessibilityLabel: "メニューバーの区画の区切り。Command キーを押したままドラッグして配置します。",
        unavailableTitle: "メニューバーの非表示は利用できません",
        unavailableCaption: "このバージョンの macOS では Vorssaint がメニューバーの項目のサイズを変更できないため、アイコンを折りたためません。メニューバーは変更されていません。",
        assessmentCaption: "このバージョンの macOS では、アプリ単位で非表示になります。メニューバーのアイコンを隠すアプリを選択してください。ドラッグするセパレーターはありません。",
        assessmentClockCaption: "アイコンを隠している間、macOS は時計へのクリックをブロックします。アイコンを再表示するまで通知センターは開きません。",
        appPickerTitle: "非表示にするアプリ",
        appPickerCaption: "実行中の他のアプリはすべて表示されたままです。新しいアプリは許可リストに自動的に追加されます。",
        applicationsFolderCaption: "この機能を使うには、Vorssaint を /Applications から実行する必要があります。ダウンロードやビルドフォルダーから実行したコピーは、自身のアイコンを隠してしまいます。",
        assessmentUnavailableCaption: "このバージョンの macOS には、Vorssaint が使用するメニューバーの非表示機能がありません。メニューバーは変更されていません。"
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
        menuTurnOff: "메뉴 막대 숨기기 끄기",
        startCollapsedToggle: "켜면 바로 접기",
        startCollapsedCaption: "화살표를 클릭할 때까지 기다리지 않고 아이콘을 바로 숨깁니다.",
        separatorAccessibilityLabel: "메뉴 막대 구역 구분선. Command 키를 누른 채 드래그하여 배치하십시오.",
        unavailableTitle: "메뉴 막대 숨기기를 사용할 수 없음",
        unavailableCaption: "이 macOS 버전에서는 Vorssaint가 메뉴 막대 항목의 크기를 조절할 수 없어 아이콘을 접을 수 없습니다. 메뉴 막대는 변경되지 않았습니다.",
        assessmentCaption: "이 macOS 버전에서는 앱별로 가립니다. 메뉴 막대 아이콘을 숨길 앱을 선택하세요. 끌어서 놓을 구분선은 없습니다.",
        assessmentClockCaption: "아이콘이 가려져 있는 동안 macOS가 시계 클릭을 차단하므로 아이콘을 다시 표시할 때까지 알림 센터가 열리지 않습니다.",
        appPickerTitle: "숨길 앱",
        appPickerCaption: "실행 중인 다른 모든 앱은 계속 표시됩니다. 새 앱은 허용 목록에 자동으로 추가됩니다.",
        applicationsFolderCaption: "이 기능이 작동하려면 Vorssaint가 /Applications에서 실행되어야 합니다. 다운로드나 빌드 폴더에서 실행한 복사본은 자체 아이콘을 숨기게 됩니다.",
        assessmentUnavailableCaption: "이 macOS 버전에는 Vorssaint가 사용하는 메뉴 막대 숨기기 기능이 없습니다. 메뉴 막대는 변경되지 않았습니다."
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
        menuTurnOff: "关闭菜单栏隐藏",
        startCollapsedToggle: "开启后立即折叠",
        startCollapsedCaption: "无需等待点击箭头，立即隐藏图标。",
        separatorAccessibilityLabel: "菜单栏区域分隔线。按住 Command 拖动以放置。",
        unavailableTitle: "菜单栏隐藏不可用",
        unavailableCaption: "此版本的 macOS 不允许 Vorssaint 调整菜单栏项目的大小，因此无法折叠图标。您的菜单栏未被更改。",
        assessmentCaption: "在此版本的 macOS 上，隐藏按应用进行：请选择要隐藏其菜单栏图标的应用。没有可拖动的分隔线。",
        assessmentClockCaption: "隐藏图标期间，macOS 会阻止点击时钟，因此在重新显示图标之前，通知中心不会打开。",
        appPickerTitle: "要隐藏的应用",
        appPickerCaption: "其他所有正在运行的应用仍会显示。新应用会自动加入允许列表。",
        applicationsFolderCaption: "此功能要求 Vorssaint 从 /Applications 运行。从“下载”或构建文件夹运行的副本会隐藏自己的图标。",
        assessmentUnavailableCaption: "此版本的 macOS 没有 Vorssaint 使用的菜单栏隐藏功能。您的菜单栏未被更改。"
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
        menuTurnOff: "關閉選單列隱藏",
        startCollapsedToggle: "開啟後立即摺疊",
        startCollapsedCaption: "不必等待點按箭頭，立即隱藏圖示。",
        separatorAccessibilityLabel: "選單列區域分隔線。按住 Command 拖曳以放置。",
        unavailableTitle: "選單列隱藏無法使用",
        unavailableCaption: "此版本的 macOS 不允許 Vorssaint 調整選單列項目的大小，因此無法摺疊圖示。您的選單列未被變更。",
        assessmentCaption: "在此版本的 macOS 上，隱藏是按應用程式進行：請選擇要隱藏其選單列圖示的應用程式。沒有可拖曳的分隔線。",
        assessmentClockCaption: "隱藏圖示期間，macOS 會阻擋點按時鐘，因此在重新顯示圖示之前，通知中心不會開啟。",
        appPickerTitle: "要隱藏的應用程式",
        appPickerCaption: "其他所有執行中的應用程式仍會顯示。新應用程式會自動加入允許清單。",
        applicationsFolderCaption: "此功能要求 Vorssaint 從 /Applications 執行。從「下載」或建置資料夾執行的副本會隱藏自己的圖示。",
        assessmentUnavailableCaption: "此版本的 macOS 沒有 Vorssaint 使用的選單列隱藏功能。您的選單列未被變更。"
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
        menuTurnOff: "關閉選單列隱藏",
        startCollapsedToggle: "開啟後立即摺疊",
        startCollapsedCaption: "不必等待點按箭嘴，立即隱藏圖示。",
        separatorAccessibilityLabel: "選單列區域分隔線。按住 Command 拖曳以放置。",
        unavailableTitle: "選單列隱藏無法使用",
        unavailableCaption: "此版本的 macOS 不允許 Vorssaint 調整選單列項目的大小，因此無法摺疊圖示。您的選單列未被變更。",
        assessmentCaption: "在此版本的 macOS 上，隱藏是按應用程式進行：請選擇要隱藏其選單列圖示的應用程式。沒有可拖曳的分隔線。",
        assessmentClockCaption: "隱藏圖示期間，macOS 會阻擋點按時鐘，因此在重新顯示圖示之前，通知中心不會開啟。",
        appPickerTitle: "要隱藏的應用程式",
        appPickerCaption: "其他所有執行中的應用程式仍會顯示。新應用程式會自動加入允許清單。",
        applicationsFolderCaption: "此功能要求 Vorssaint 從 /Applications 執行。從「下載」或建置資料夾執行的副本會隱藏自己的圖示。",
        assessmentUnavailableCaption: "此版本的 macOS 沒有 Vorssaint 使用的選單列隱藏功能。您的選單列未被變更。"
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
        menuExpand: "Показати приховані об’єкти",
        menuCollapse: "Приховати об’єкти",
        menuEnableAutoCollapse: "Увімкнути автозгортання",
        menuDisableAutoCollapse: "Вимкнути автозгортання",
        menuShowSections: "Показати завжди прихований розділ",
        menuHideSections: "Приховати завжди прихований розділ",
        menuSettings: "Налаштування…",
        menuTurnOff: "Вимкнути приховування в рядку меню",
        startCollapsedToggle: "Згортати одразу після ввімкнення",
        startCollapsedCaption: "Приховує значки відразу, не чекаючи натискання на стрілку.",
        separatorAccessibilityLabel: "Розділювач розділу рядка меню. Утримуйте Command і перетягніть, щоб розмістити його.",
        unavailableTitle: "Приховування в рядку меню недоступне",
        unavailableCaption: "Ця версія macOS не дозволяє Vorssaint змінювати розмір елементів рядка меню, тому значки не можна згорнути. Рядок меню залишився без змін.",
        assessmentCaption: "У цій версії macOS приховування працює за програмами: виберіть програми, чиї значки в рядку меню потрібно приховати. Розділювача для перетягування немає.",
        assessmentClockCaption: "Поки значки приховані, macOS блокує натискання на годинник, тому Центр сповіщень не відкриється, доки ви знову не покажете значки.",
        appPickerTitle: "Програми для приховування",
        appPickerCaption: "Усі інші запущені програми залишаються видимими. Нові програми автоматично додаються до списку дозволених.",
        applicationsFolderCaption: "Щоб це працювало, Vorssaint має запускатися з /Applications. Копія, запущена зі «Завантажень» або теки збірки, приховає власний значок.",
        assessmentUnavailableCaption: "У цій версії macOS немає засобу приховування рядка меню, який використовує Vorssaint. Рядок меню залишився без змін."
    )
}
