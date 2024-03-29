import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nexus_mobile_app/bloc/organization_bloc/organization_bloc.dart';
import 'package:nexus_mobile_app/bloc/repositories/organization_repository.dart';
import 'package:nexus_mobile_app/bloc/update_bloc/update_bloc.dart';
import 'package:nexus_mobile_app/models/models.dart';
import 'package:nexus_mobile_app/ui/components/SearchButton.dart';
import 'package:nexus_mobile_app/ui/components/NSliverIconButton.dart';
import 'package:nexus_mobile_app/ui/components/tiles/UpdateTile.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class UpdatePage extends StatelessWidget {
  final Update update;

  UpdatePage(this.update);

  @override
  Widget build(BuildContext context) {
    String text = update.update_text;
    return Scaffold(
        body: SafeArea(
            child: ListView(shrinkWrap: true, children: <Widget>[
      Row(children: [
        Padding(
            padding: EdgeInsets.only(left: 14.0, bottom: 14.0),
            child: IconButton(
                icon: Icon(Icons.chevron_left, size: 36.0),
                onPressed: () => Navigator.of(context).pop()))
      ]),
      Padding(
          padding: new EdgeInsets.only(left: 36.0, right: 36.0),
          child: Theme(
              data: Theme.of(context).copyWith(
                  textTheme:
                      Theme.of(context).textTheme.apply(fontSizeFactor: 2.0)),
              child: HtmlWidget(
                text,
                tableCellPadding: EdgeInsets.all(0),
              ))),
    ])));
  }
}

class UpdatesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    OrganizationRepository rep =
        BlocProvider.of<OrganizationBloc>(context).repository;
    return BlocBuilder<UpdateBloc, UpdateState>(builder: (context, state) {
      if (state is UpdateStateUninitialized)
        context.bloc<UpdateBloc>().add(UpdateEventPage());
      return RefreshIndicator(
          onRefresh: () {
            Completer completer = new Completer();
            context.bloc<UpdateBloc>().add(UpdateEventRefresh(completer));
            return completer.future;
          },
          child: CustomScrollView(slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 100.0,
              actions: <Widget>[
                SearchButton(),
              ],
              elevation: 0,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Updates',
                  style: TextStyle(color: Colors.black),
                ),
                collapseMode: CollapseMode.parallax,
              ),
            ),
            buildList(state)
          ]));
    });
  }

  Widget buildList(UpdateState state) {
    if (state is UpdateStateNoData) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('No Updates',
                      style: new TextStyle(fontSize: 16.0, color: Colors.grey)),
                  Text('Pull to Refresh',
                      style: new TextStyle(fontSize: 12.0, color: Colors.grey)),
                ],
              ),
            );
          },
          childCount: 1,
        ),
      );
    } else if (state is UpdateStateHasData) {
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: UpdateTile(update: state.updates[index]),
          );
        }, childCount: state.updates.length),
      );
    }
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      return Text("loading");
    }, childCount: 1));
  }
}
