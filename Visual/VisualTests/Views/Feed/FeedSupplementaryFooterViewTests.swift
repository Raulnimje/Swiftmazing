//
//  FeedSupplementaryFooterViewTests.swift
//  VisualTests
//
//  Created by Helio Loredo Mesquita on 06/01/20.
//  Copyright © 2020 Hélio Mesquita. All rights reserved.
//

import Quick
import Nimble
import Nimble_Snapshots

@testable import Visual

class FeedSupplementaryFooterViewTests: QuickSpec {

    override func spec() {

        describe("FeedSupplementaryFooterView") {

            var view: FeedSupplementaryFooterView!

            beforeEach {
                view = FeedSupplementaryFooterView(frame: CGRect(x: 0, y: 0, width: 375, height: 40))
            }

            it("returns the layout") {
//                expect(view) == recordSnapshot()
                expect(view) == snapshot()
            }
        }
    }
}
