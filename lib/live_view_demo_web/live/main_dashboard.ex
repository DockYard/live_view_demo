defmodule LiveViewDemoWeb.MainDashboard do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="mainBG flex-one centerItems avoid-header">
      <div>
      <div class="display-flex">
        <div class="row space-around">
          <div class="text-center">
            <h2>Visualixir</h2>
            <img src="images/logo_v1_circle.png" width="150" height="150"/>
          </div>
          <div class="paragraph-container">
            <h2>About</h2>
            <p>
              Visualixir is a data visualization tool inspired in
              <a href="https://superset.incubator.apache.org/" target="_blank">
                Apache's Superset
              </a>. It connects to your DB and lets you
              make charts selecting data from your tables. It
              also includes a SQL Lab where you can run custom queries.
            </p>
            <p>
              This tool was developed as my entry for the Phoenix Phrenzy contest.
            </p>
          </div>
        </div>
      </div>
      <div class="middle-container-db">
        <div class="mainContainer text-center">
          <h2 class="little-margin-top">Try it out</h2>
          <div class="display-flex">
            <div class="row space-around">
              <a href="/chart" class="db-box">
                <img src="images/logo_v1_circle.png" width="120" height="120"/>
                <h3> Charts </h3>
              </a>
              <a href="/examples" class="db-box">
                <img src="images/logo_v1_circle.png" width="120" height="120"/>
                <h3> Examples </h3>
              </a>
              <a href="/sql-lab" class="db-box">
                <img src="images/logo_v1_circle.png" width="120" height="120"/>
                <h3> SQL Lab </h3>
              </a>
            </div>
          </div>
        </div>
      </div>
      <div class="final-p extended-paragraph-container">
        <h2>What's next?</h2>
        <p>
          Building this was very fun and exciting. A lot of "it feels like cheating" moments.
        </p>
        <p>
          Find it interesting? Check out
          <a href="https://github.com/Ian-GL/live_view_demo" target="_blank">
            the repo
          </a>
          . If you wanna contribute, ask questions, or just say hi you can drop
          me a line at ian.gl@protonmail.com or if you prefer Twitter:
          <a href="https://twitter.com/ian_sparky" target="_blank">
            @ian_sparky
          </a>
        </p>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, socket}
  end

end
