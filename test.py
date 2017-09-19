import os
import pylast

API_KEY = "efadf48ab3d1300a9e67806e78980bdd"
API_SECRET = "7648e2b0c8add66b75c5d5ae3ad208be"

id_vect = [];
tit_vect = [];
alb_vect = [];
art_vect = [];

def read_db():
    id_raw = os.popen("grep '####' $MOEFM_DATABASE/database | awk -F '####' '{print $1}'").read()
    buf = '';
    for i in id_raw:
        if i != '\n':
            buf+=i;
        else:
            id_vect.append(buf);
            buf='';
    
    tit_raw = os.popen("grep '####' $MOEFM_DATABASE/database | awk -F '####' '{print $2}'").read()
    buf = '';
    for i in tit_raw:
        if i != '\n':
            buf+=i;
        else:
            tit_vect.append(buf);
            buf='';

    alb_raw = os.popen("grep '####' $MOEFM_DATABASE/database | awk -F '####' '{print $3}'").read()
    buf = '';
    for i in alb_raw:
        if i != '\n':
            buf+=i;
        else:
            alb_vect.append(buf);
            buf='';

    art_raw = os.popen("grep '####' $MOEFM_DATABASE/database | awk -F '####' '{print $4}'").read()
    buf = '';
    for i in art_raw:
        if i != '\n':
            buf+=i;
        else:
            art_vect.append(buf);
            buf='';

def db_decode():
    for i in range(1,len(id_vect)):
        print("YES!!!!!");
        id_vect[i]=id_vect[i].replace('%20',' ');
        tit_vect[i]=tit_vect[i].replace('%20',' ');
        alb_vect[i]=alb_vect[i].replace('%20',' ');
        art_vect[i]=art_vect[i].replace('%20',' ');
        id_vect[i]=id_vect[i].replace('&#039;','\'');
        tit_vect[i]=tit_vect[i].replace('&#039;','\'');
        alb_vect[i]=alb_vect[i].replace('&#039;','\'');
        art_vect[i]=art_vect[i].replace('&#039;','\'');

        print (id_vect[i])
        print (tit_vect[i])
        print (alb_vect[i])
        print (art_vect[i])
        print('\n')
            
read_db();
db_decode();
print("YES!");

