import SwiftUI
import SwiftData

struct ConstellationGalleryView: View {
    @Query var capsules: [TimeCapsule]
    @State private var viewModel = ConstellationViewModel()
    @State private var selectedCapsuleFilter: TimeCapsule? = nil
    @State private var threadsOpacity: Double = 0
    @State private var starsOpacity: Double = 0

    @State private var currentZoom: CGFloat = 1.0
    @State private var totalZoom: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var totalOffset: CGSize = .zero

    var zoom: CGFloat {
        max(0.3, min(5.0, currentZoom * totalZoom))
    }
    var offset: CGSize {
        CGSize(
            width: currentOffset.width + totalOffset.width,
            height: currentOffset.height + totalOffset.height
        )
    }

    var allMemories: [Memory] {
        capsules.flatMap { $0.memories }
    }

    var filteredMemories: [Memory] {
        guard let filter = selectedCapsuleFilter
        else { return allMemories }
        return allMemories.filter {
            $0.capsule?.id == filter.id
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0B0C1E").ignoresSafeArea()
                BackgroundStarsView().ignoresSafeArea()

                if allMemories.isEmpty {
                    emptyState
                } else {
                    if capsules.count > 1 {
                        VStack {
                            capsuleFilterPills
                                .padding(.top, 8)
                            Spacer()
                        }
                        .zIndex(20)
                    }

                    GeometryReader { geo in
                        ZStack {

                            ConstellationThreadsView(
                                clusters: viewModel.clusters,
                                opacity: threadsOpacity
                            )
                            .allowsHitTesting(false)
                            .zIndex(0)

                            ForEach(viewModel.clusters) {
                                cluster in
                                if cluster.isCluster {
                                    ClusterLabelView(
                                        cluster: cluster,
                                        isSelected:
                                            viewModel
                                            .selectedMemory?
                                            .id == cluster.id
                                    )
                                    .position(
                                        x: cluster.center.x,
                                        y: cluster.center.y
                                            - labelOffset(
                                                for: cluster
                                            )
                                    )
                                    .opacity(threadsOpacity)
                                    .zIndex(8)
                                    .onLongPressGesture(
                                        minimumDuration: 0.4
                                    ) {
                                        withAnimation {
                                            viewModel
                                            .showTooltip(
                                                for: cluster.id
                                            )
                                        }
                                        UIImpactFeedbackGenerator(
                                            style: .light
                                        ).impactOccurred()
                                    }
                                }
                            }

                            ForEach(viewModel.starNodes) {
                                node in
                                let memory = memoryForNode(node)
                                let isInSelected =
                                    viewModel.selectedMemory?
                                    .id == node.memoryID

                                if let memory = memory {
                                    StarThumbnailView(
                                        memory: memory,
                                        photoIndex:
                                            node.photoIndex,
                                        isSelected:
                                            viewModel
                                            .selectedMemory?
                                            .id == node.memoryID
                                            && viewModel
                                            .selectedMemory?
                                            .id == node.memoryID,
                                        isInSelectedCluster:
                                            isInSelected,
                                        isDimmed: isDimmed(node),
                                        onTap: {
                                            withAnimation(
                                                .spring(
                                                    response: 0.4,
                                                    dampingFraction:
                                                        0.75
                                                )
                                            ) {
                                                viewModel
                                                .selectMemory(
                                                    memory
                                                )
                                            }
                                        },
                                        onLongPress: {
                                            withAnimation {
                                                viewModel
                                                .showTooltip(
                                                    for: memory.id
                                                )
                                            }
                                        }
                                    )
                                    .position(node.position)
                                    .opacity(starsOpacity)
                                    .zIndex(isInSelected ? 5 : 1)
                                    .animation(
                                        .easeIn(duration: 0.4)
                                        .delay(
                                            appearDelay(node)
                                        ),
                                        value: starsOpacity
                                    )
                                }
                            }

                            ForEach(viewModel.clusters) {
                                cluster in
                                if viewModel.tooltipMemoryID
                                    == cluster.id {
                                    StarTooltipView(
                                        memory: cluster.memory
                                    )
                                    .position(
                                        x: cluster.center.x,
                                        y: max(
                                            80,
                                            cluster.center.y - 70
                                        )
                                    )
                                    .zIndex(15)
                                    .transition(
                                        .scale(scale: 0.8)
                                        .combined(with: .opacity)
                                    )
                                }
                            }
                        }
                        .scaleEffect(zoom, anchor: .center)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { v in
                                    currentZoom = v
                                }
                                .onEnded { v in
                                    totalZoom = max(
                                        0.3,
                                        min(5.0, totalZoom * v)
                                    )
                                    currentZoom = 1.0
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { v in
                                    currentOffset =
                                        v.translation
                                }
                                .onEnded { v in
                                    totalOffset = CGSize(
                                        width: totalOffset.width
                                            + v.translation.width,
                                        height: totalOffset.height
                                            + v.translation.height
                                    )
                                    currentOffset = .zero
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(
                                .spring(response: 0.4,
                                        dampingFraction: 0.8)
                            ) {
                                currentZoom = 1.0
                                totalZoom = 1.0
                                currentOffset = .zero
                                totalOffset = .zero
                            }
                        }
                        .onAppear {
                            viewModel.buildClusters(
                                for: filteredMemories,
                                in: geo.size
                            )
                            animateAppear()
                        }
                        .onChange(of: selectedCapsuleFilter) {
                            _, _ in
                            viewModel.buildClusters(
                                for: filteredMemories,
                                in: geo.size
                            )
                        }
                        .onChange(of: filteredMemories.count) {
                            _, _ in
                            viewModel.buildClusters(
                                for: filteredMemories,
                                in: geo.size
                            )
                        }
                    }
                    .zIndex(1)

                    if totalZoom != 1.0
                        || totalOffset != .zero {
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    withAnimation(
                                        .spring(
                                            response: 0.4,
                                            dampingFraction: 0.8
                                        )
                                    ) {
                                        currentZoom = 1.0
                                        totalZoom = 1.0
                                        currentOffset = .zero
                                        totalOffset = .zero
                                    }
                                } label: {
                                    Image(systemName:
                                        "arrow.up.left.and.down.right.magnifyingglass"
                                    )
                                    .font(.body)
                                    .frame(width: 36, height: 36)
                                }
                                .glassEffect(
                                    .regular.interactive(),
                                    in: .circle
                                )
                                .padding(16)
                            }
                            Spacer()
                        }
                        .zIndex(25)
                        .transition(.scale.combined(with: .opacity))
                    }

                    VStack {
                        Spacer()
                        EmotionLegendView(
                            onEmotionFilter: { emotion in
                                filterByEmotion(emotion)
                            }
                        )
                        .padding(.bottom, 24)
                    }
                    .zIndex(20)
                }
            }
            .navigationTitle("Constellation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .sheet(item: $viewModel.selectedMemory) { memory in
            MemoryCardSheetView(
                memory: memory,
                capsule: memory.capsule
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
            .presentationBackground(Color(hex: "0D0D1A"))
        }
    }

    private func animateAppear() {
        withAnimation(.easeIn(duration: 0.5)) {
            starsOpacity = 1.0
        }
        withAnimation(
            .easeIn(duration: 0.9).delay(0.5)
        ) {
            threadsOpacity = 1.0
        }
    }

    private func appearDelay(_ node: StarNode) -> Double {
        let clusterIndex = viewModel.clusters.firstIndex {
            $0.id == node.memoryID
        } ?? 0
        let starIndex = viewModel.starNodes.filter {
            $0.memoryID == node.memoryID
        }.firstIndex { $0.id == node.id } ?? 0

        return Double(clusterIndex) * 0.12
            + Double(starIndex) * 0.05
    }

    private func labelOffset(
        for cluster: MemoryCluster
    ) -> CGFloat {
        switch cluster.photoCount {
        case 2: return 48
        case 3: return 62
        case 4: return 68
        case 5: return 74
        default: return 80
        }
    }

    private func isDimmed(_ node: StarNode) -> Bool {
        guard let selected = viewModel.selectedMemory
        else { return false }
        return node.memoryID != selected.id
    }

    private func memoryForNode(
        _ node: StarNode
    ) -> Memory? {
        allMemories.first { $0.id == node.memoryID }
    }

    private func filterByEmotion(_ emotion: Emotion?) {
    }

    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.3))
            Text("No memories yet")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.5))
            Text("Add memories with photos to see\nyour constellation form")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
    }

    var capsuleFilterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            GlassEffectContainer(spacing: 8) {
                HStack(spacing: 8) {
                    Button {
                        withAnimation {
                            selectedCapsuleFilter = nil
                            viewModel.buildClusters(
                                for: allMemories,
                                in: .zero
                            )
                        }
                    } label: {
                        Text("All")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                    }
                    .glassEffect(
                        selectedCapsuleFilter == nil
                            ? .regular.tint(
                                .white.opacity(0.2)
                            ).interactive()
                            : .regular.interactive(),
                        in: .capsule
                    )

                    ForEach(capsules) { capsule in
                        Button {
                            withAnimation {
                                selectedCapsuleFilter = capsule
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName:
                                    capsule.milestoneType.systemImage
                                )
                                .font(.caption2)
                                Text(capsule.name)
                                    .font(.caption.bold())
                                    .lineLimit(1)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                        }
                        .glassEffect(
                            selectedCapsuleFilter?.id
                                == capsule.id
                                ? .regular.tint(
                                    Color(
                                        hex: capsule
                                        .accentColorHex
                                    ).opacity(0.4)
                                ).interactive()
                                : .regular.interactive(),
                            in: .capsule
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
