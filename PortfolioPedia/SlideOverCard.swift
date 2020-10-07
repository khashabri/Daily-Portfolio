import SwiftUI


@available(iOS 13.0, *)
public struct SlideOverCardBlack<Content> : View where Content : View {
    @Binding var tabBarHeight: CGFloat
    @Binding var defaultPosition : CardPosition
    @Binding var backgroundStyle: BackgroundStyle
    var content: () -> Content
    
    public init(tabBarHeight: Binding<CGFloat>,_ position: Binding<CardPosition> = .constant(.middle), backgroundStyle: Binding<BackgroundStyle> = .constant(.solid), content: @escaping () -> Content) {
        self.content = content
        self._tabBarHeight = tabBarHeight
        self._defaultPosition = position
        self._backgroundStyle = backgroundStyle
    }
     
    public var body: some View {
        ModifiedContent(content: self.content(), modifier: Card(tabBarHeight: self.$tabBarHeight, colorScheme: false, position: self.$defaultPosition, backgroundStyle: self.$backgroundStyle))
       }
}

public struct SlideOverCardLight<Content> : View where Content : View {
    @Binding var tabBarHeight: CGFloat
    @Binding var defaultPosition : CardPosition
    @Binding var backgroundStyle: BackgroundStyle
    var content: () -> Content
    
    public init(tabBarHeight: Binding<CGFloat>, _ position: Binding<CardPosition> = .constant(.middle), backgroundStyle: Binding<BackgroundStyle> = .constant(.solid), content: @escaping () -> Content) {        self.content = content
        self._tabBarHeight = tabBarHeight
        self._defaultPosition = position
        self._backgroundStyle = backgroundStyle
    }
     
    public var body: some View {
        ModifiedContent(content: self.content(), modifier: Card(tabBarHeight: self.$tabBarHeight, colorScheme: true, position: self.$defaultPosition, backgroundStyle: self.$backgroundStyle))
       }
}

public enum BackgroundStyle {
    case solid, clear, blur
}

public enum CardPosition: CGFloat {
    
    case bottom , middle, top
    
    func offsetFromTop(tabBarHeight: CGFloat) -> CGFloat {
        switch self {
        case .bottom:
            return tabBarHeight
        case .middle:
            return tabBarHeight/2
        case .top:
            return 80 // 0 oberste Rand vor dem Safe Area
        }
    }
}

enum DragState {
    
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}



struct Card: ViewModifier {
    @Binding var tabBarHeight: CGFloat
    @State var colorScheme: Bool
    @GestureState var dragState: DragState = .inactive
    @Binding var position : CardPosition
    @Binding var backgroundStyle: BackgroundStyle
    @State var offset: CGSize = CGSize.zero
    
    var animation: Animation {
        Animation.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 20.0)
    }
    
    var timer: Timer? {
        return Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            if self.position == .top && self.dragState.translation.height == 0  {
                self.position = .top
            } else {
                timer.invalidate()
            }
        }
    }
    
    func body(content: Content) -> some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in state = .dragging(translation:  drag.translation) }
            .onChanged {_ in
                self.offset = .zero
        }
        .onEnded(onDragEnded)
        
        return ZStack(alignment: .top) {
            ZStack(alignment: .top) {

                if backgroundStyle == .blur {
                    BlurView(style: colorScheme == false ? .dark : .extraLight)
                }

                if backgroundStyle == .clear {
                    Color.clear
                }

                if backgroundStyle == .solid {
                    colorScheme == true ? Color.black : Color.white
                }

                Handle()
                content.padding(.top, 23)
            }
            .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(x: 1, y: 1, anchor: .center)
        }
        .offset(y:  max(0, self.position.offsetFromTop(tabBarHeight: tabBarHeight) + self.dragState.translation.height))
        .animation((self.dragState.isDragging ? animation : animation))
        .gesture(drag)
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        
        // Setting stops
        let higherStop: CardPosition
        let lowerStop: CardPosition
        
        // Nearest position for drawer to snap to.
        let nearestPosition: CardPosition
        
        // Determining the direction of the drag gesture and its distance from the top
        let dragDirection = drag.predictedEndLocation.y - drag.location.y
        let offsetFromTopOfView = position.offsetFromTop(tabBarHeight: tabBarHeight) + drag.translation.height
        
        // Determining whether drawer is above or below `.partiallyRevealed` threshold for snapping behavior.
        if offsetFromTopOfView <= CardPosition.middle.offsetFromTop(tabBarHeight: tabBarHeight) {
//            higherStop = .top
            higherStop = .middle
            lowerStop = .middle
        } else {
            higherStop = .middle
//            lowerStop = .middle
            lowerStop = .bottom
        }
        
        // Determining whether drawer is closest to top or bottom
        if (offsetFromTopOfView - higherStop.offsetFromTop(tabBarHeight: tabBarHeight)) < (lowerStop.offsetFromTop(tabBarHeight: tabBarHeight) - offsetFromTopOfView) {
            nearestPosition = higherStop
        } else {
            nearestPosition = lowerStop
        }
        
        // Determining the drawer's position.
        if dragDirection > 0 {
            position = lowerStop
        } else if dragDirection < 0 {
            position = higherStop
        } else {
            position = nearestPosition
        }
        _ = timer
    }
}

@available(iOS 13.0, *)
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<BlurView>) {}

}

@available(iOS 13.0, *)
struct Handle : View {
    private let handleThickness = CGFloat(5.0)
    var body: some View {
        RoundedRectangle(cornerRadius: handleThickness / 2.0)
            .frame(width: 40, height: handleThickness)
            .foregroundColor(Color.secondary)
            .padding(5)
    }
}
