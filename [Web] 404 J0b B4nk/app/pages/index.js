import Head from "next/head";

export default function Home() {
  return (
    <>
      <Head>
        <meta charSet="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>404 J0b B4nk</title>
      </Head>
      <nav className="navbar navbar-expand-lg navbar-dark bg-dark mb-5">
        <div className="container">
          <a className="navbar-brand fw-bold" href="/">404 J0b B4nk</a>
          <button className="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span className="navbar-toggler-icon"></span>
          </button>
          <div className="collapse navbar-collapse" id="navbarNav">
            <ul className="navbar-nav ms-auto">
              <li className="nav-item active">
                <a className="nav-link" href="/">Home</a>
              </li>
            </ul>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="jumbotron text-center mb-4">
        <div className="container">
          <h1 className="display-4 fw-bold">The <span className="gradient">Next Station</span> in Your Career</h1>
          <p className="lead">Discover new opportunities and take your career to the next level.</p>
          <a href="#" className="btn btn-primary">Get Started</a>
        </div>
      </section>

      {/* Colorful Section */}
      <section className="colorful-section mb-4">
        <div className="container">
          <h2 className="text-center mb-4">Why Choose Us?</h2>
          <hr />
          <div className="row">
            <div className="col-lg-4">
              <h4>Expert Guidance</h4>
              <p>We provide personalized career guidance from experienced professionals in your industry. Our experts are dedicated to helping you navigate your career path and achieve your goals.</p>
            </div>
            <div className="col-lg-4">
              <h4>Career Resources</h4>
              <p>Access our extensive library of career resources, including resume templates, interview tips, and industry-specific guides. Our resources are designed to empower you with the knowledge and tools to succeed in your career.</p>
            </div>
            <div className="col-lg-4">
              <h4>Growth Opportunities</h4>
              <p>We believe in your potential for growth and provide you with a range of opportunities to enhance your skills and advance your career. From professional development programs to networking events, we offer avenues for your continuous growth.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section className="team">
        <div className="container">
          <h2 className="text-center mb-4">Meet Our Team</h2>
          <div className="row">
            <div className="col-md-4">
              <div className="team-member">
                <img src="/api/team?id=1" alt="Team Member 1" />
                <h4>CHW</h4>
                <p>Founder</p>
              </div>
            </div>
            <div className="col-md-4">
              <div className="team-member">
                <img src="/api/team?id=2" alt="Team Member 2" />
                <h4>Sl33p1ng R0ck</h4>
                <p>Lead Developer</p>
              </div>
            </div>
            <div className="col-md-4">
              <div className="team-member">
                <img src="/api/team?id=3" alt="Team Member 3" />
                <h4>R0ck Sm0k3r</h4>
                <p>Chief Security Officer</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <footer className="bg-dark text-white text-center py-3">
        <div className="container">
          <p>&copy; 2025 404 J0b B4nk. All rights reserved.</p>
        </div>
      </footer>
    </>
  )
}
