package org.jfxworks.connect44fx.servlet;

import java.io.IOException;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.jfxworks.connect44fx.dao.ScoreDao;
import org.jfxworks.connect44fx.entity.Score;

public class SaveScoreServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger log = Logger.getLogger(SaveScoreServlet.class.getName());
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		log.info("SaveScoreServlet: in doGet");
		doPost(req, resp);
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		log.info("SaveScoreServlet: in doPost");
		
		try {
			Score score = new Score();
			String userId = (String) req.getAttribute("userId");
			String value = (String) req.getAttribute("value");			
			score.setUserId(userId);
			score.setValue(Integer.valueOf(value));
			
			log.info("Saving score userId: " + score.getUserId() + " and highscore: " + score.getValue());
			
			ScoreDao scoreDao = new ScoreDao();
			scoreDao.saveScore(score);
		} catch (Exception e) {
			log.throwing(SaveScoreServlet.class.getName(), "doPost", e);
			throw new ServletException(e);
		}
	}
}
