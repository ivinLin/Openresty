local template = require("resty.template");

local content = {
    title = "i'am title",
    headDesc = "Hello, template world"
}

template.render("h1.html", content);
