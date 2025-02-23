//
//  PagedInfiniteScrollView.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/28/23.
//


import SwiftUI
import UIKit

struct PagedInfiniteScrollView<S: Steppable & Comparable, Content: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIPageViewController

    let content: (S) -> Content
    @Binding var currentPage: S

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        let initialViewController = UIHostingController(rootView: IdentifiableContent(index: currentPage, content: { content(currentPage) }))
        pageViewController.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)

        return pageViewController
    }

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        let currentViewController = uiViewController.viewControllers?.first as? UIHostingController<IdentifiableContent<Content, S>>
        let currentIndex = currentViewController?.rootView.index ?? .origin

        if currentPage != currentIndex {
            let direction: UIPageViewController.NavigationDirection = currentPage > currentIndex ? .forward : .reverse
            let newViewController = UIHostingController(rootView: IdentifiableContent(index: currentPage, content: { content(currentPage) }))
            uiViewController.setViewControllers([newViewController], direction: direction, animated: true, completion: nil)
        }
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PagedInfiniteScrollView

        init(_ parent: PagedInfiniteScrollView) {
            self.parent = parent
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let currentView = viewController as? UIHostingController<IdentifiableContent<Content, S>>, let currentIndex = currentView.rootView.index as S? else {
                return nil
            }

            let previousIndex = currentIndex.backward()

            return UIHostingController(rootView: IdentifiableContent(index: previousIndex, content: { parent.content(previousIndex) }))
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let currentView = viewController as? UIHostingController<IdentifiableContent<Content, S>>, let currentIndex = currentView.rootView.index as S? else {
                return nil
            }

            let nextIndex = currentIndex.forward()

            return UIHostingController(rootView: IdentifiableContent(index: nextIndex, content: { parent.content(nextIndex) }))
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
               let currentView = pageViewController.viewControllers?.first as? UIHostingController<IdentifiableContent<Content, S>>,
               let currentIndex = currentView.rootView.index as S? {
                parent.currentPage = currentIndex
            }
        }
    }
}

extension PagedInfiniteScrollView {
    struct IdentifiableContent<Content: View, S: Steppable>: View {
        let index: S
        let content: Content

        init(index: S, @ViewBuilder content: () -> Content) {
            self.index = index
            self.content = content()
        }

        var body: some View {
            content
        }
    }
}
