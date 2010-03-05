package org.jfxworks.connect44fx.dao;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import org.datanucleus.store.query.QueryResult;
import org.jfxworks.connect44fx.entity.Score;


public class ScoreDao {
	
	public void saveScore(Score score) {
		PersistenceManager persistenceManager = PMF.get().getPersistenceManager();
		try {
			persistenceManager.makePersistent(score);
		} finally {
			persistenceManager.close();
		}
	}
	
	public Score loadScoreByUser(String userId) {
		PersistenceManager persistenceManager = PMF.get().getPersistenceManager();
		try {
			Query query = persistenceManager.newQuery(Score.class);
			query.setFilter("userId == userIdParam");
			query.declareParameters("String userIdParam");
			QueryResult queryResult = (QueryResult)query.execute(userId);
			
			Score result = null;
			if(queryResult.size() > 0) {
				result  = (Score)queryResult.iterator().next();
			}
			
			return result;
		} finally {
			persistenceManager.close();
		}
	}
}
