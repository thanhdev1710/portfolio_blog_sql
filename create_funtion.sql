CREATE OR REPLACE FUNCTION generate_unique_slug()
RETURNS TRIGGER AS $$
DECLARE
	base_slug TEXT;
	new_slug TEXT;
	counter int := 1;
BEGIN
	-- Tạo slug từ title
	base_slug := LOWER(REPLACE(TRIM(NEW.title),' ','-'));
	
	-- Gán new_slug = base_slug
  	new_slug := base_slug;
  	
  	LOOP
  		EXIT WHEN NOT EXISTS (SELECT 1 FROM posts WHERE slug = new_slug);
  		new_slug := base_slug || '-' || counter;
  		counter := counter + 1;
  	END LOOP;
  	
  	NEW.title := TRIM(NEW.title);
  	NEW.slug := new_slug;
  	
  	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_generate_slug
BEFORE INSERT OR UPDATE ON posts
FOR EACH ROW
EXECUTE FUNCTION generate_unique_slug();
