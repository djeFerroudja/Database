-----------------------------------------------------------------------------------------------
--  [1]  Quel est la liste des séries de la base ?   --
-----------------------------------------------------------------------------------------------
SELECT * FROM SERIE;

-----------------------------------------------------------------------------------------------
--  [2] Combien de pays différents ont créé des séries dans notre base ?
-----------------------------------------------------------------------------------------------
SELECT COUNT(DISTINCT ORIGINE) AS NB_PAYS FROM SERIE ;

-----------------------------------------------------------------------------------------------
--  [3] Quels sont les titres des séries originaires du Japon, triés par titre ?
-----------------------------------------------------------------------------------------------
SELECT TITRE_SERIE FROM SERIE WHERE ORIGINE='Japon' ORDER BY TITRE_SERIE ASC;

-----------------------------------------------------------------------------------------------
--  [4] Combien y a-t-il de séries originaires de chaque pays ?
SELECT ORIGINE, COUNT(TITRE_SERIE) AS NB_PAYS FROM SERIE GROUP BY ORIGINE;

-----------------------------------------------------------------------------------------------
--  [5] Combien de séries ont été créés entre 2001 et 2015?
-----------------------------------------------------------------------------------------------
SELECT COUNT(TITRE_SERIE) AS NB_PAYS FROM (SELECT ANNEE,TITRE_SERIE FROM SERIE WHERE ANNEE BETWEEN 2001 AND 2015);

-----------------------------------------------------------------------------------------------
--  [6] Quelles séries sont à la fois du genre « Comédie » et « Science-Fiction » ?
-----------------------------------------------------------------------------------------------
SELECT DISTINCT TITRE_SERIE FROM GENRE_DE_SERIE WHERE GENRE in('Comedie','Science-fiction');

----------------------------------------------------------------------------------------------------
--  [7] Quels sont les séries produites par « Spielberg », affichés par date décroissantes ?
-----------------------------------------------------------------------------------------------
SELECT TITRE_SERIE FROM SERIE_PRODUITE WHERE PRENOM_PERS = 'Spielberg';
SELECT TITRE_SERIE FROM SERIE S NATURAL JOIN SERIE_PRODUITE SP WHERE SP.NOM_PERS='Spielberg' OR SP.PRENOM_PERS='Spielberg' ORDER BY S.ANNEE DESC;---ici le order by sert juste pour l'affichage

----------------------------------------------------------------------------------------------------
--  [8] Afficher les séries Américaines par ordre de nombre de saisons croissant.
-----------------------------------------------------------------------------------------------
SELECT  TITRE_SERIE,COUNT(SAISON) AS NB_SAISON  FROM SAISONS NATURAL JOIN SERIE WHERE ORIGINE = 'Etats-Unis' GROUP BY TITRE_SERIE ORDER BY NB_SAISON DESC;

SELECT TITRE_SERIE,COUNT(SA.SAISON) AS NB_SAISON FROM SERIE S NATURAL JOIN SAISONS SA GROUP BY TITRE_SERIE,S.ORIGINE HAVING S.ORIGINE='Etats-Unis' ORDER BY NB_SAISON DESC;

----------------------------------------------------------------------------------------------------
--  [9] Quelle série a le plus d’épisodes ?
-----------------------------------------------------------------------------------------------
SELECT TITRE_SERIE,COUNT(E.EPISODE) AS NB_EPISODE FROM EPISODES E GROUP BY TITRE_SERIE HAVING COUNT(E.EPISODE)>=ALL(SELECT COUNT(EPISODE) FROM EPISODES GROUP BY TITRE_SERIE);

----------------------------------------------------------------------------------------------
--  [10] La série « Big Bang Theory » est-elle plus appréciée des hommes ou des femmes ?
-----------------------------------------------------------------------------------------------
--  METHODE AVEC LES VUES

CREATE VIEW UTILISATEUR_M_F AS (SELECT TITRE_SERIE,SEXE,AVG(NOTE) AS NOTE FROM UTILISATEURS FULL JOIN AVIS_SERIE USING(PSEUDO) GROUP BY TITRE_SERIE,SEXE);

SELECT (CASE WHEN MF.SEXE='M' THEN 'HOMMES' WHEN MF.SEXE='F' THEN 'FEMMES' ELSE 'EGAUX' END) AS APRECIER_PAR_LES  FROM UTILISATEUR_M_F MF WHERE MF.TITRE_SERIE='Big Bang Theory' AND MF.SEXE=(SELECT SEXE FROM UTILISATEUR_M_F WHERE TITRE_SERIE=MF.TITRE_SERIE AND NOTE =(SELECT MAX(NOTE) FROM UTILISATEUR_M_F WHERE TITRE_SERIE=MF.TITRE_SERIE));

----------------------------------------------------------------------------------------------
--  [11] Affichez les séries qui ont une note moyenne inférieure à 5, classé par note.
-----------------------------------------------------------------------------------------------
SELECT TITRE_SERIE, AVG(NOTE) AS NOTE_MOY FROM AVIS_SERIE GROUP BY TITRE_SERIE HAVING AVG(NOTE)<5;
---- methode 2: avec une Vue
CREATE VIEW SERIE_NOTE  AS SELECT TITRE_SERIE,AVG(NOTE) AS NOTE_MOY FROM UTILISATEURS NATURAL JOIN AVIS_SERIE GROUP BY TITRE_SERIE;
SELECT TITRE_SERIE,NOTE_MOY FROM SERIE_NOTE WHERE NOTE_MOY<5 ;

-----------------------------------------------------------------------------------------------
--  [12] Pour chaque série, afficher le commentaire correspondant à la meilleure note.
-----------------------------------------------------------------------------------------------
SELECT TITRE_SERIE, COMMENTAIRE FROM AVIS_SERIE WHERE NOTE=(SELECT MAX(NOTE)FROM AVIS_SERIE);
-- methode avec les vues
CREATE VIEW SERIE_EVALUER AS SELECT TITRE_SERIE,NOTE,COMMENTAIRE,PSEUDO FROM UTILISATEURS NATURAL JOIN AVIS_SERIE;
SELECT TITRE_SERIE,COMMENTAIRE FROM SERIE_EVALUER WHERE NOTE=(SELECT MAX(NOTE) FROM SERIE_EVALUER);
----------------------------------------------------------------------------------------------
--  [13] Affichez les séries qui ont une note moyenne sur leurs épisodes supérieure à 8.
-----------------------------------------------------------------------------------------------
SELECT TITRE_SERIE, AVG(NOTE) AS NOTE_MOYENNE FROM (SELECT E.PSEUDO, S.TITRE_SERIE, P.TITRE_EPISODE,NOTE FROM AVIS_EPISODE E,SERIE S, EPISODES P WHERE E.TITRE_EPISODE= P.TITRE_EPISODE AND P.TITRE_SERIE= S.TITRE_SERIE) GROUP BY TITRE_SERIE HAVING AVG(NOTE)>8;
----- MEHODE 2
SELECT TITRE_SERIE,AVG(NOTE) AS NOTE_MOYENNE  FROM EPISODES NATURAL JOIN AVIS_EPISODE GROUP BY TITRE_SERIE HAVING AVG(NOTE)>8 ;
----------------------------------------------------------------------------------------------
--  [14] Afficher le nombre moyen d’épisodes des séries avec l’acteur « Bryan Cranston ».
-----------------------------------------------------------------------------------------------
SELECT TITRE_SERIE,COUNT(TITRE_EPISODE) AS NB_MOY_EP FROM(SELECT NOM_PERS, TITRE_EPISODE, TITRE_SERIE FROM ACTEUR_PARTICIPE_EPISODE JOIN EPISODES USING(TITRE_EPISODE) WHERE NOM_PERS ='Bryan' AND PRENOM_PERS='Craston') GROUP BY TITRE_SERIE;
--- METHODE 2
SELECT TITRE_SERIE,COUNT(EPISODE) AS NB_MOY_EP FROM EPISODES NATURAL JOIN ACTEUR_PARTICIPE_EPISODE WHERE (NOM_PERS='Bryan' AND PRENOM_PERS='Craston') GROUP BY TITRE_SERIE;

-----------------------------------------------------------------------------------------------
--  [15] Quels acteurs ont réalisé des épisodes de série ?
-----------------------------------------------------------------------------------------------
SELECT DISTINCT NOM_PERS,PRENOM_PERS,TITRE_SERIE FROM ACTEUR_PARTICIPE_EPISODE NATURAL JOIN EPISODES ;

-----------------------------------------------------------------------------------------------
--  [16] Quels acteurs ont joué ensemble dans plus de 80% des épisodes d’une série ?
-----------------------------------------------------------------------------------------------
SELECT NOM_PERS, PRENOM_PERS TITRE_SERIE FROM ACTEUR_PARTICIPE_EPISODE NATURAL JOIN EPISODES GROUP BY NOM_PERS, PRENOM_PERS HAVING COUNT(*)>=ALL (SELECT 0.8*COUNT(*) FROM EPISODES  GROUP BY TITRE_EPISODE);

----------------------------------------------------------------------------------------------
--  [17] Quels acteurs ont joué dans tous les épisodes de la série « Breaking Bad » ?
 SELECT NOM_PERS,PRENOM_PERS , COUNT(TITRE_EPISODE) AS NB_EP_PARTICIPE FROM (SELECT  NOM_PERS,PRENOM_PERS,titre_episode,TITRE_SERIE FROM ACTEUR_PARTICIPE_EPISODE NATURAL JOIN EPISODES WHERE TITRE_SERIE='Breaking Bad') GROUP BY NOM_PERS, PRENOM_PERS HAVING COUNT(TITRE_EPISODE) =  (SELECT COUNT(TITRE_EPISODE) FROM EPISODES WHERE TITRE_SERIE='Breaking Bad');

 ----------------------------------------------------------------------------------------------
--  [18] Quels utilisateurs ont donné une note à chaque série de la base ?
-----------------------------------------------------------------------------------------------
CREATE VIEW UTILISATEUR_NB_SERIE AS (SELECT PSEUDO,COUNT(TITRE_SERIE) AS NB_SERIE FROM AVIS_SERIE GROUP BY PSEUDO);
SELECT PSEUDO FROM UTILISATEUR_NB_SERIE WHERE NB_SERIE=(SELECT COUNT(TITRE_SERIE) AS NB_TITRE FROM SERIE);

----------------------------------------------------------------------------------------------
--  [19] Pour chaque message, affichez son niveau et si possible le titre de la série en question.
-----------------------------------------------------------------------------------------------
SELECT PSEUDO1,PSEUDO2,LEVEL,RPAD(' ', LEVEL-1) || TYPE_MESSAGE||' '||TITRE_SERIE AS TITRE FROM FORUM START WITH PSEUDO2 IS NULL CONNECT BY NOCYCLE PSEUDO2=PRIOR PSEUDO1;

----------------------------------------------------------------------------------------------
--  [20] Les messages initiés par « Azrod95 » génèrent combien de réponses en moyenne ?
-----------------------------------------------------------------------------------------------
CREATE VIEW PSEUDO1_NB_MESSAGE AS(SELECT PSEUDO2,COUNT(MESSAGE) AS NB_MESSAGE FROM FORUM GROUP BY PSEUDO2);
SELECT COUNT(DISTINCT MESSAGE) AS NB_MESSAGE FROM FORUM WHERE TYPE_MESSAGE='Re';
SELECT PSEUDO2,(NB_MESSAGE/(SELECT COUNT(DISTINCT MESSAGE) FROM FORUM WHERE TYPE_MESSAGE='Re'))AS MOYENNE FROM PSEUDO1_NB_MESSAGE WHERE PSEUDO2='Azrod95';
