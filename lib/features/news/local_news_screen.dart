import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/common_widget/post_card_widget.dart';
import 'package:nearhood/common_widget/shimmer_post_card.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/core/utils/share_helper.dart';
import 'package:nearhood/features/news/bloc/news_bloc.dart';
import 'package:nearhood/features/news/bloc/news_event.dart';
import 'package:nearhood/features/news/bloc/news_state.dart';
import 'package:nearhood/features/news/data/news_datasource.dart';
import 'package:nearhood/features/news/data/news_repository.dart';
import 'package:nearhood/features/post/bloc/post_action_bloc.dart';
import 'package:nearhood/features/post/bloc/post_action_event.dart';
import 'package:nearhood/features/post/bloc/post_action_state.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';
import 'package:nearhood/features/post/data/post_datasource.dart';
import 'package:nearhood/features/post/data/post_repository.dart';
import 'package:nearhood/features/post/screens/post_detail_screen.dart';

class LocalNewsScreen extends StatelessWidget {
  final String initialMode;

  const LocalNewsScreen({super.key, this.initialMode = 'city'});

  @override
  Widget build(BuildContext context) {
    final postRepository = PostRepository(dataSource: PostRemoteDataSource());
    final newsRepository = NewsRepository(dataSource: NewsRemoteDataSource());

    return MultiBlocProvider(
      providers: [
        BlocProvider<NewsBloc>(
          create: (context) => NewsBloc(repository: newsRepository)
            ..add(FetchLocalNewsRequested(refresh: true, mode: initialMode)),
        ),
        BlocProvider<PostActionBloc>(
          create: (context) => PostActionBloc(repository: postRepository),
        ),
      ],
      child: _LocalNewsView(initialMode: initialMode),
    );
  }
}

class _LocalNewsView extends StatelessWidget {
  final String initialMode;

  const _LocalNewsView({required this.initialMode});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PostActionBloc, PostActionState>(
          listener: (context, state) {
            if (state.status == ApiCallState.success) {
              if (state.actionType == 'like' || state.actionType == 'unlike') {
                final newsBloc = context.read<NewsBloc>();
                final existingPostIndex = newsBloc.state.posts.indexWhere(
                  (p) => p.id == state.postId,
                );

                if (existingPostIndex != -1) {
                  final existingPost = newsBloc.state.posts[existingPostIndex];
                  final updatedPost = PostModel(
                    id: existingPost.id,
                    author: existingPost.author,
                    content: existingPost.content,
                    category: existingPost.category,
                    mediaUrls: existingPost.mediaUrls,
                    localityPlaceId: existingPost.localityPlaceId,
                    city: existingPost.city,
                    localityName: existingPost.localityName,
                    visibilityRadius: existingPost.visibilityRadius,
                    maxRadiusMeters: existingPost.maxRadiusMeters,
                    isPinned: existingPost.isPinned,
                    isResolved: existingPost.isResolved,
                    isDeleted: existingPost.isDeleted,
                    commentCount: existingPost.commentCount,
                    reactions: state.reactions ?? existingPost.reactions,
                    topComments: existingPost.topComments,
                    createdAt: existingPost.createdAt,
                    updatedAt: existingPost.updatedAt,
                    attachedLocation: existingPost.attachedLocation,
                    poll: existingPost.poll,
                    metadata: existingPost.metadata,
                  );
                  newsBloc.add(UpdateLocalNewsPostRequested(updatedPost));
                }
              } else if (state.actionType == 'vote' && state.post != null) {
                context.read<NewsBloc>().add(
                  UpdateLocalNewsPostRequested(state.post!),
                );
              } else if (state.actionType == 'delete') {
                AppSnackBar.showMessage(
                  context,
                  'Post deleted successfully',
                  borderColor: AppColors.green,
                );
                context.read<NewsBloc>().add(
                  FetchLocalNewsRequested(refresh: true, mode: initialMode),
                );
              }
            } else if (state.status == ApiCallState.failure) {
              AppSnackBar.showMessage(
                context,
                state.message ?? 'Action failed',
                borderColor: AppColors.red,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CommonAppBar(title: 'Local News'),
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<NewsBloc, NewsState>(
            builder: (context, state) {
              final showBottomLoader =
                  state.status == ApiCallState.busy && state.posts.isNotEmpty;

              if (state.status == ApiCallState.busy && state.posts.isEmpty) {
                return const ShimmerPostCardList();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NewsBloc>().add(
                    FetchLocalNewsRequested(refresh: true, mode: state.mode),
                  );
                },
                child: state.posts.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: state.status == ApiCallState.failure
                            ? EmptyStateWidget(
                                title: 'Unable to load local news',
                                subtitle:
                                    state.message ??
                                    'Please pull down to refresh or try again later.',
                                btnText: AppStrings.retry,
                                onPressed: () {
                                  context.read<NewsBloc>().add(
                                    FetchLocalNewsRequested(
                                      refresh: true,
                                      mode: state.mode,
                                    ),
                                  );
                                },
                              )
                            : EmptyStateWidget(
                                title: 'No local news yet',
                                subtitle:
                                    'We will show trusted city updates here once stories are available.',
                                showButton: false,
                              ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          final shouldLoadMore =
                              notification.metrics.pixels >=
                                  notification.metrics.maxScrollExtent - 200 &&
                              state.status != ApiCallState.busy &&
                              !state.hasReachedMax;

                          if (shouldLoadMore) {
                            context.read<NewsBloc>().add(
                              FetchLocalNewsRequested(mode: state.mode),
                            );
                          }

                          return false;
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
                          itemCount:
                              state.posts.length + (showBottomLoader ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.posts.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: WaveDotsLoader(
                                    color: AppColors.primaryBlue,
                                    size: 8,
                                  ),
                                ),
                              );
                            }

                            final post = state.posts[index];
                            final currentUser = sharedPrefGetUser();
                            final isLiked =
                                currentUser != null &&
                                post.reactions.any(
                                  (r) => r.userId == currentUser.id,
                                );

                            return PostCardWidget(
                              post: post,
                              onLikeTap: () {
                                if (isLiked) {
                                  context.read<PostActionBloc>().add(
                                    UnlikePostRequested(post.id),
                                  );
                                } else {
                                  context.read<PostActionBloc>().add(
                                    LikePostRequested(post.id),
                                  );
                                }
                              },
                              onReactTap: (reaction) {
                                context.read<PostActionBloc>().add(
                                  ReactToPostRequested(post.id, reaction),
                                );
                              },
                              onCommentTap: () {
                                callNextScreenWithResult(
                                  context,
                                  PostDetailScreen(post: post),
                                ).then((_) {
                                  if (!context.mounted) return;
                                  context.read<NewsBloc>().add(
                                    FetchLocalNewsRequested(
                                      refresh: true,
                                      mode: state.mode,
                                    ),
                                  );
                                });
                              },
                              onBodyTap: () {
                                callNextScreenWithResult(
                                  context,
                                  PostDetailScreen(post: post),
                                ).then((_) {
                                  if (!context.mounted) return;
                                  context.read<NewsBloc>().add(
                                    FetchLocalNewsRequested(
                                      refresh: true,
                                      mode: state.mode,
                                    ),
                                  );
                                });
                              },
                              onPollOptionTap: (optionId) {
                                context.read<PostActionBloc>().add(
                                  VotePollRequested(post.id, optionId),
                                );
                              },
                              onShareTap: () {
                                sharePost(post);
                              },
                            );
                          },
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
