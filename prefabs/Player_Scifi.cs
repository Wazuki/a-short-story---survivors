using Godot;
using System;
using System.Diagnostics;
using System.Reflection.Metadata;

public partial class Player_Scifi : CharacterBody2D
{
    [Export]
    float health = 100f;

    float DamageRate = 5.0f;
    int experience = 0;
    int level = 1;
    int xpToNextLevel = 10;


    [Export]
    private float speed = 450;

    private Area2D hurtBox;
    private Area2D weaponRange;

    //struct Spreadfire
    //{
    //    public int level;
    //    public int projectiles;
    //    public int damage;
    //    public float speed;
    //    public bool readyToFire = true;

    //    public Spreadfire()
    //    {
    //        this.level = 1;
    //        this.projectiles = 1;
    //        this.damage = 1;
    //        this.speed = 750f;
    //    }

    //    public void LevelUp()
    //    {
    //        level++;
    //        if (level % 2 == 1) projectiles++; //Gain projectiles on odd levels
    //        else damage++;
    //    }

    //    //public void DebugOutput()
    //    //{
    //    //    Debug.Print("Spreadshot:\n" + "Level: " + level + "\n" + "Damage: " + damage + "\n" + "Projectiles: " + projectiles + "\n" + "Speed: "+ speed + "\n");

    //    //}
    //} 
    //Spreadfire spreadfire;
    //private readonly PackedScene spreadfireBullet = ResourceLoader.Load<PackedScene>("res://spreadfire.tscn");
    private AnimatedSprite2D animationPlayer;

    [Signal]
    public delegate void HealthDepletedEventHandler();
    //Normal update
    public override void _Ready()
    {
        hurtBox = GetNode<Area2D>("%HurtBox");
        weaponRange = GetNode<Area2D>("%WeaponRange");
        animationPlayer = GetNode<AnimatedSprite2D>("%Spritesheet");
    }


    //Fixed update basically - use for physics shit
    public override void _PhysicsProcess(double delta)
    {
        //if(Input.IsKeyPressed(Key.Escape)) GetTree().Quit(); //Temporary quit option

        //GetVector() turns movement into 2D direction
        Vector2 direction = Input.GetVector("move_left", "move_right", "move_up", "move_down");

        Velocity = direction * speed;
        MoveAndSlide(); //Automatically move character based on velocity. Applies delta automatically

        //Animation recreated!
        //Length() is not zero if we have ANY velocity
        if (Velocity.Length() > 0.0)
        {
            animationPlayer.Animation = "player_walk";
            animationPlayer.Play();
        }
        else ///TODO - stop the animation from stopping so aggressively. AnimationPlayer Finished signal?
        {
            animationPlayer.Animation = "player_idle";
        }

        var overlappingMobs = hurtBox.GetOverlappingBodies();

        if(overlappingMobs.Count > 0)
        {
            health -= DamageRate * overlappingMobs.Count * (float)delta; //Deal damage for each mob touching the player, times delta so it's not full damage EVERY frame

            GetNode<ProgressBar>("%HealthBar").Value = health;

            if(health <= 0)
            {
                EmitSignal(SignalName.HealthDepleted); //Emit the player's death signal, handled by the HealthDepleted signal/delegate
                //Debug.Print("death");
            }
        }

        FireWeapons();

        //Tell the XP orbs in t he pickup radius to start absorbing
        var xpToAbsorb = GetNode<Area2D>("%PickupRadius").GetOverlappingAreas();

        foreach(ExperienceOrb e  in xpToAbsorb)
        {
            e.Absorbing = true;
            AudioStreamPlayer2D audioStreamPlayer2D = GetNode<AudioStreamPlayer2D>("%XPPickupSound");
            if(!audioStreamPlayer2D.IsPlaying()) audioStreamPlayer2D.Play();
        }
    }

    public void FireWeapons()
    {
        var mobsInRange = weaponRange.GetOverlappingBodies();

        if (mobsInRange.Count > 0)
        {
            //Fire the weapon at the first mob; if successful, play the weapon sound
            //Debug.Print("Firing " + Spreadfire.Instance.Name);
            if (Spreadfire.Instance.FireWeapon(mobsInRange[0].GlobalPosition, this)) //Play the audio if we actually fire the weapon
            {
                AudioStreamPlayer2D audioStreamPlayer2D = GetNode<AudioStreamPlayer2D>("%SpreadshotWeaponSound");
                if (!audioStreamPlayer2D.Playing) audioStreamPlayer2D.Play();
            }
        }
    }

    //private void OnSpreadshotTimerTimeout()
    //{
    //    spreadfire.readyToFire = true;
    //}

    //private void SpawnSpreadshotBullet(Vector2 targetPos, float angle)
    //{
    //    var newBullet = spreadfireBullet.Instantiate<Node2D>();
    //    newBullet.GlobalPosition = GlobalPosition;
    //    newBullet.GlobalRotation = GlobalRotation;
    //    newBullet.LookAt(targetPos);
    //    newBullet.GlobalRotation += Mathf.DegToRad(angle);
    //    //sfb.Target(mobsInRange[p].GlobalPosition);
    //    SpreadfireBullet sfb = newBullet as SpreadfireBullet;
    //    sfb.Speed = spreadfire.speed;
    //    AddChild(newBullet);
    //    newBullet.Position = Vector2.Zero; //Set the bullet to start at the player's pos (local position)
    //    spreadfire.readyToFire = false;
    //    GetNode<Timer>("%SpreadshotTimer").Start();
    //}

    public void GainExperience(int xp)
    {
        experience += xp;
        if (xp >= xpToNextLevel)
        {
            LevelUp();
        }
    }

    private void LevelUp()
    {
        //1: Show the level up UI
        //2: Show the available weapon options, level them up accordingly
        //3: Rest next level xp
        AudioStreamPlayer2D audioStreamPlayer2D = GetNode<AudioStreamPlayer2D>("%LevelUpSound");
        if (!audioStreamPlayer2D.IsPlaying()) audioStreamPlayer2D.Play();
        //Spreadfire.Instance.LevelUp();
        //GameScene.Instance.UpdateLevelUp(Spreadfire.Instance.level, Spreadfire.Instance.damage, Spreadfire.Instance.projectiles);

        experience -= xpToNextLevel;
        level++;

        GameScene.Instance.DisplayLevelUp();
    }

}
