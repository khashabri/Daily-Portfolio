import SwiftUI
import URLImage

var link = "https://logo.clearbit.com/"
var rest = "?format=jpg"

struct LogoView : View {
    
    // let url: URL
    let name_of_company: String
    
    var body: some View {
        URLImage(cast2URL(string: link+name_of_company+rest),
                 placeholder: {
                    ProgressView($0) { progress in
                        ZStack {
                            if progress > 0.0 {
                                CircleProgressView(progress).stroke(lineWidth: 8.0)
                            }
                            else {
                                CircleActivityView().stroke(lineWidth: 50.0)
                            }
                        }
                    }
                    .frame(width: 50.0, height: 50.0)
        },
                 content: {
                    $0.image
                        .resizable()
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                        .frame(width: 70, height: 70)
                        .aspectRatio(contentMode: .fit)
        })
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView(name_of_company: "Apple")
    }
}
