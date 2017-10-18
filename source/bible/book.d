module bible.book;

import bible.chapter;

class Book {
	string m_bookTitle;
	Chapter[] m_chapters;
	
	this( string bookTitle ) {
		m_bookTitle = bookTitle;
	}
}
