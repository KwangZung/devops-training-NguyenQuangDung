CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

INSERT INTO items (name) VALUES ('Initial Item 1'), ('Initial Item 2');