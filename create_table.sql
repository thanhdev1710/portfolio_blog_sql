CREATE TYPE role_enum AS ENUM ('admin', 'author', 'editor', 'subscriber');

CREATE TABLE users
(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	email VARCHAR(255) NOT NULL UNIQUE,
	image TEXT NOT NULL,
	role role_enum DEFAULT 'subscriber',
	password VARCHAR(300) NOT NULL,
	password_reset_token VARCHAR(255),
	password_reset_expires TIMESTAMP WITH TIME ZONE,
	password_changed_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE posts
(
	id SERIAL PRIMARY KEY,
	title VARCHAR(50) NOT NULL,
	slug VARCHAR(100) NOT NULL UNIQUE,
	content TEXT NOT NULL,
	summary TEXT NOT NULL,
	duration INT NOT NULL DEFAULT 1,
	image_url TEXT,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	status CHAR(7) CHECK(status IN ('private','public')) DEFAULT 'public',
	views INT DEFAULT 0,
	user_id INT NOT NULL,  -- Thêm trường user_id
	search_vector tsvector,
	CONSTRAINT FK_posts_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE  -- Thiết lập FK
);

CREATE TABLE post_sections (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL,
    title VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    image_url TEXT,
    alt_text VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    position INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT image_alt_check CHECK (
        (image_url IS NOT NULL AND alt_text IS NOT NULL) OR 
        (image_url IS NULL AND alt_text IS NULL)
    ),
    CONSTRAINT fk_post FOREIGN KEY (post_id)
        REFERENCES posts(id)
        ON DELETE CASCADE
);

CREATE TABLE categories
(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL UNIQUE
);


CREATE TABLE posts_categories (
    post_id INT NOT NULL,
    category_id INT NOT NULL,
    CONSTRAINT PK_posts_categories PRIMARY KEY (post_id, category_id),
    CONSTRAINT FK_posts_categories_posts FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    CONSTRAINT FK_posts_categories_categories FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);


CREATE TABLE tags
(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE posts_tags
(
	post_id INT,
	tag_id INT,
	CONSTRAINT PK_posts_tags PRIMARY KEY (post_id, tag_id),
	CONSTRAINT FK_posts_tags_posts FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
	CONSTRAINT FK_posts_tags_tags FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

CREATE TABLE comments
(
	id SERIAL PRIMARY KEY,
	post_id INT NOT NULL,
	user_id INT NOT NULL,
	parent_id INT,
	body VARCHAR(200) NOT NULL,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT FK_comments_parent FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE,
	CONSTRAINT FK_comments_posts FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
	CONSTRAINT FK_comments_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE likes (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    user_id INT NOT NULL,
    post_id INT,
    comment_id INT,
    status VARCHAR(7) CHECK (
        status IN ('like', 'dislike')
    ) DEFAULT 'like',
    CONSTRAINT likes_check CHECK(
        COALESCE((post_id) :: BOOL :: INT, 0) + COALESCE((comment_id) :: BOOL :: INT, 0) = 1
    ),
    CONSTRAINT likes_comment_unique UNIQUE(user_id, comment_id),
	CONSTRAINT likes_post_unique UNIQUE(user_id, post_id),
    CONSTRAINT fk_likes_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_likes_post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    CONSTRAINT fk_likes_comment FOREIGN KEY (comment_id) REFERENCES comments(id) ON DELETE CASCADE
);

CREATE TABLE bookmarks (
	created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	user_id INT NOT NULL,
	post_id INT NOT NULL,
	CONSTRAINT PK_bookmarks PRIMARY KEY (user_id,post_id),
	CONSTRAINT fk_bookmarks_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	CONSTRAINT fk_bookmarks_posts FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
)
