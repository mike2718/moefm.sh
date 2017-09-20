#!/usr/bin/python
#coding:utf-8
import os;
import pylast;
import time;
import sys;
import imp;
imp.reload(sys)
# imp.sys.setdefaultencoding('utf8')


API_KEY = "efadf48ab3d1300a9e67806e78980bdd"
API_SECRET = "7648e2b0c8add66b75c5d5ae3ad208be"

username="your_username";
password_hash = pylast.md5("your_password");



network = pylast.LastFMNetwork(api_key=API_KEY, api_secret=API_SECRET,
                               username=username, password_hash=password_hash)


# Use this function to scrobble...

def Scrobble_one(title, album, artist):
    print("TITLE:"+title+"\nALBUM:"+album+"\nART:"+artist);
        
    # Search Round 1
    # Accurate Search
    if artist != '未知':
        search = network.search_for_track(artist,title);
        tracks = search.get_next_page();
        if len(tracks) > 0:
            network.scrobble(tracks[0].get_artist(), tracks[0].get_name(), time.time(), tracks[0].get_album());
            print("Round 1 FOUND!");
            return;
    
    # Search Round 2
    # Keyword Search

    sear_vec=[];
    print(title);
    buf = '';

        # Clip every word into search_vector
    
    for i in range(0, len(title)):
        if title[i] == ' ':
            sear_vec.append(buf);
            buf = '';
        else:
            buf += title[i];

    if artist != '未知':


        sear_vec.append(buf);
        # last one
        
        for i in range(0, len(sear_vec)):
            print(sear_vec[i]);

            search = network.search_for_track(artist,sear_vec[i]);
            tracks = search.get_next_page();
            if len(tracks) > 0:
                network.scrobble(tracks[0].get_artist(), tracks[0].get_name(), time.time(), tracks[0].get_album());
                print("Round 2 FOUND!");
                return;


    # Search Round 3 -> Album Search
    if album != '未知':
        search = network.search_for_album(album);
        albums = search.get_next_page();

        if len(albums) > 0:
            art = albums[0].get_artist();

            # Traceback and search track...
            # search = network.search_for_track(art, sear_vec[0]);
            # tracks = search.get_next_page();
            # # In round search
            # if len(tracks) > 0:
            #     network.scrobble(tracks[0].get_artist(), tracks[0].get_name(), time.time(), tracks[0].get_album());
            #     print("Round 2+ FOUND!");
            #     return;
            # VERY DANGEROUS...

            # Note: this part of search hardly hit the target...
            # So I removed it...


            
            # Still can't find track... Force add...
            network.scrobble(albums[0].get_artist(), title, time.time(), albums[0].get_name());
            print("Round 3 FOUND!");
            return;

    # If still can't fetch.........
    # Huhuhuhuhu~~~~~~Generate Album Information
    if album != '未知':
        network.scrobble(artist, title, time.time(), album);
    else:
        network.scrobble(artist, title, time.time());

    print("Never found!");

    


def Love_one(title, album, artist):
    print("TITLE:"+title+"\nALBUM:"+album+"\nART:"+artist);
        
    # Search Round 1
    # Accurate Search
    if artist != '未知':
        search = network.search_for_track(artist,title);
        tracks = search.get_next_page();
        if len(tracks) > 0:
            tracks[0].love();
            print("Round 1 FOUND!");
            return;
    
    # Search Round 2
    # Keyword Search

    sear_vec=[];
    print(title);
    buf = '';


    
    for i in range(0, len(title)):
        if title[i] == ' ':
            sear_vec.append(buf);
            buf = '';
        else:
            buf += title[i];

    if artist != '未知':


        sear_vec.append(buf);

        
        for i in range(0, len(sear_vec)):
            print(sear_vec[i]);

            search = network.search_for_track(artist,sear_vec[i]);
            tracks = search.get_next_page();
            if len(tracks) > 0:
                track[0].love();
                print("Round 2 FOUND!");
                return;


    # Search Round 3 -> Album Search
    if album != '未知':
        search = network.search_for_album(album);
        albums = search.get_next_page();

        if len(albums) > 0:
            art = albums[0].get_artist();
            loved = pylast.Track(albums[0].get_artist(), title, network);
            loved.love();
            
            print("Round 3 FOUND!");
            return;

    # Generate Round

    if album != '未知':
        loved = pylast.Track(artist, title, network);
    else:
        loved = pylast.Track(artist, title, network);

    loved.love();
        

