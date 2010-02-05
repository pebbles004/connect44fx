package org.jfxworks.connect44fx.web;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.NoResultException;
import javax.persistence.Persistence;
import javax.persistence.Query;
import javax.ws.rs.Path;
import javax.ws.rs.GET;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;

/**
 * REST Web Service to manage the games' scores.
 *
 * @author jan
 */
@Path("")
public class ScoreResource {

    private static final EntityManagerFactory EMF = Persistence.createEntityManagerFactory( "transactions-optional" );
    private static final Logger LOGGER = Logger.getLogger( ScoreResource.class.getSimpleName() );

    /**
     * Service method to get the high scores of a game.
     *
     * Example url to reach this method: http://<domain of the game>/scores/<name of the game>/high
     *
     * This method returns an updated version of the high scores
     *
     * @param game Unique id of the game (ie "invaders")
     */
    @GET
    @Produces("text/plain")
    @Path("{game}/high")
    public String getAllScores( @PathParam("game") String game ) {
        LOGGER.info( "Request for high scores of " + game );

        EntityManager entityManager = null;
        try {
            entityManager = EMF.createEntityManager();
            Query query = entityManager.createQuery( "SELECT g FROM Game g JOIN FETCH g.scores s WHERE g.name = :name");// ORDER BY s.score DESC" );
            query.setParameter( "name", game );
            Object object = query.getSingleResult();
            List<Score> scores = ( (Game) object ).getScores();
            if ( scores != null ) {
                StringBuffer result = new StringBuffer();
                for ( Score score : scores ) {
                    if ( result.length() > 0 ) {
                        result.append( "\n" );
                    }
                    result.append( score.getPlayerId() ).append( "," ).append( score.getScore() );
                }
                return result.toString();
            }
        } catch( NoResultException nre ) {
        } finally {
            if ( entityManager != null ) {
                entityManager.close();
            }
        }
        return "NO SCORES FOUND FOR GAME '" + game + "'";
    }

    /**
     * Service method to add a score to the high scores of a game.
     *
     * Example url to reach this method: http://<domain of the game>/scores/<name of the game>/add?name=<name of the player>&score=<score>
     *
     * This method returns an updated version of the high scores
     *
     * @param game Unique id of the game (ie. "invaders")
     * @param namePlayer Unique id of the player
     * @param score Score to be added
     */
    @GET
    @Produces("text/plain")
    @Path("{game}/add")
    public String addScore( @PathParam("game") String game, @QueryParam("name") String namePlayer, @QueryParam("score") int score ) {

        EntityManager entityManager = null;
        try {
            entityManager = EMF.createEntityManager();
            entityManager.getTransaction().begin();
            try {
                // where's that game ?
                Query query = entityManager.createQuery( "SELECT g FROM Game g WHERE g.name = :name" );
                query.setParameter( "name", game );
                Object object = query.getSingleResult();
                // if no nre was thrown, the game is there
                ((Game)object).getScores().add( new Score( namePlayer, score ));
                entityManager.merge( object );
            } catch ( NoResultException nre ) {
                // this game has not been found yet - let's create it
                List<Score> scores = new ArrayList<Score>();
                scores.add( new Score( namePlayer, score ) );
                Game temp = new Game();
                temp.setName( game );
                temp.setScores( scores );
                entityManager.persist( temp );
            }
            entityManager.flush();
            entityManager.getTransaction().commit();
        } catch ( Exception e ) {
            if ( entityManager != null ) {
                entityManager.getTransaction().rollback();
            }
        } finally {
            if ( entityManager != null ) {
                entityManager.close();
            }
        }

        // return an updated list of scores
        return getAllScores( game );
    }
}
